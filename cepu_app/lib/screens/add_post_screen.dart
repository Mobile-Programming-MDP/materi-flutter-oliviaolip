import 'dart:convert';

import 'package:cepu_app/models/post.dart';
import 'package:cepu_app/services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  String? _base64Image;
  String? _latitude;
  String? _longitude;
  String? _category;

  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  bool _isPickingImage = false;

  List<String> get categories => [
        'Jalan Rusak',
        'Lampu Jalan Mati',
        'Lawan Arah',
        'Merokok di Jalan',
        'Tidak Pakai Helm'
      ];

  // ✅ PICK + COMPRESS IMAGE (tidak freeze)
  Future<void> pickImageAndConvert() async {
    setState(() => _isPickingImage = true);

    try {
      final picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (image != null) {
        final bytes = await image.readAsBytes();

        final compressed = await FlutterImageCompress.compressWithList(
          bytes,
          quality: 60,
        );

        setState(() {
          _base64Image = base64Encode(compressed);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error pick image: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  // ✅ GET LOCATION (pakai loading)
  Future<void> _getLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Layanan lokasi dinonaktifkan.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Izin lokasi ditolak.")),
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil lokasi.")),
      );
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  // ✅ PILIH KATEGORI
  void _showCategorySelect() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: categories.map((cat) {
            return ListTile(
              title: Text(cat),
              onTap: () {
                setState(() => _category = cat);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // ✅ PREVIEW IMAGE
  Widget _buildImagePreview() {
    if (_base64Image == null) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: const Text('Belum ada gambar dipilih'),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        base64Decode(_base64Image!),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // ✅ INFO LOKASI
  Widget _buildLocationInfo() {
    if (_latitude == null || _longitude == null) {
      return const Text('Lokasi belum diambil');
    }
    return Text('Lat: $_latitude\nLng: $_longitude',
        textAlign: TextAlign.center);
  }

  // ✅ SUBMIT POST (SUDAH FIX SEMUA BUG)
  Future<void> _submitPost() async {
    if (_base64Image == null ||
        _descriptionController.text.trim().isEmpty ||
        _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Lengkapi gambar, kategori, dan deskripsi")),
      );
      return; // 🔥 penting
    }

    setState(() => _isSubmitting = true);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final fullName = FirebaseAuth.instance.currentUser?.displayName;

    try {
      if (_latitude == null || _longitude == null) {
        await _getLocation(); // 🔥 wajib await
      }

      await PostService.addPost(
        Post(
          image: _base64Image,
          description: _descriptionController.text,
          category: _category,
          latitude: _latitude,
          longitude: _longitude,
          userId: userId,
          userFullName: fullName, // 🔥 samakan dengan service
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Posting berhasil disimpan")),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Posting gagal: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isSubmitting || _isGettingLocation || _isPickingImage;

    return Scaffold(
      appBar: AppBar(title: const Text("Add new post")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: isBusy ? null : pickImageAndConvert,
              child: Text(_isPickingImage ? 'Memproses gambar...' : 'Pick Image'),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: isBusy ? null : _showCategorySelect,
              child: const Text('Select Category'),
            ),

            const SizedBox(height: 8),

            Text(
              _category ?? 'Belum memilih kategori',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: isBusy ? null : _getLocation,
              child: Text(
                _isGettingLocation ? 'Mengambil Lokasi...' : 'Get Location',
              ),
            ),

            const SizedBox(height: 8),
            _buildLocationInfo(),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: isBusy ? null : _submitPost,
              child:
                  Text(_isSubmitting ? 'Submitting...' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}