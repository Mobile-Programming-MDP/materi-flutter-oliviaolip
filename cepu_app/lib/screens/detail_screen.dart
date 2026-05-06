import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cepu_app/models/post.dart';
import 'package:cepu_app/screens/map_detail_screen.dart'; // ✅ tambahan

class DetailPostScreen extends StatelessWidget {
  final Post post;

  const DetailPostScreen({super.key, required this.post});

  // ✅ buka Google Maps
  Future<void> _openMap() async {
    final String url =
        'https://www.google.com/maps/search/?api=1&query=${post.latitude},${post.longitude}';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  // ✅ share
  Future<void> _sharePost() async {
    final text = '''
Post dari ${post.userFullName ?? 'Unknown'}

Kategori: ${post.category ?? '-'}

${post.description ?? '-'}

Lokasi: ${post.latitude}, ${post.longitude}
''';

    await Share.share(text, subject: 'Cek post ini dari Cepu App!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 IMAGE
            if (post.image != null && post.image!.isNotEmpty)
              Image.memory(
                base64Decode(post.image!),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey,
                child: const Center(child: Text('No Image')),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 USER
                  Text(
                    post.userFullName ?? 'Unknown User',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  // 🏷️ CATEGORY
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue[100],
                    child: Text(post.category ?? '-'),
                  ),

                  const SizedBox(height: 16),

                  // 📝 DESCRIPTION
                  Text(post.description ?? '-'),

                  const SizedBox(height: 16),

                  // 📍 LOCATION
                  Text('Lat: ${post.latitude}'),
                  Text('Lng: ${post.longitude}'),

                  const SizedBox(height: 16),

                  // 🌍 GOOGLE MAPS
                  ElevatedButton(
                    onPressed: _openMap,
                    child: const Text('Open Map (Google Maps)'),
                  ),

                  const SizedBox(height: 8),

                  // 🗺️ MAP APP (FLUTTER MAP)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MapDetailScreen(post: post),
                        ),
                      );
                    },
                    child: const Text('Lihat di Map App'),
                  ),

                  const SizedBox(height: 8),

                  // 🔗 SHARE
                  ElevatedButton(
                    onPressed: _sharePost,
                    child: const Text('Share'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}