import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cepu_app/models/post.dart';

class DetailPostScreen extends StatelessWidget {
  final Post post;

  const DetailPostScreen({super.key, required this.post});
  
  get Uri => null;

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
                  Text(
                    post.userFullName ?? 'Unknown User',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue[100],
                    child: Text(post.category ?? '-'),
                  ),
                  const SizedBox(height: 16),
                  Text(post.description ?? '-'),
                  const SizedBox(height: 16),
                  Text('Lat: ${post.latitude}'),
                  Text('Lng: ${post.longitude}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _openMap,
                    child: const Text('Open Map'),
                  ),
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