import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_downloader/image_downloader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html
    if (dart.library.io) 'gallery_page_stub.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  Future<List<String>> fetchImageUrls() async {
    const apiUrl = String.fromEnvironment('GALLERY_URL',
        defaultValue: 'https://YOUR_API_GATEWAY_ENDPOINT/gallery');
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Dacă răspunsul este {"images": [...]}
      if (data is Map && data['images'] is List) {
        return List<String>.from(data['images']);
      }
      // Dacă răspunsul este direct o listă
      if (data is List) {
        return data.cast<String>();
      }
      // Dacă răspunsul este {"photos": [{...}]}
      if (data is Map && data['photos'] is List) {
        return (data['photos'] as List)
            .where((photo) => photo is Map && photo['url'] != null)
            .map<String>((photo) => photo['url'] as String)
            .toList();
      }
      throw Exception('Format necunoscut de răspuns');
    } else {
      throw Exception('Nu s-au putut încărca imaginile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Acasă',
        ),
        title: const Text('Galerie Foto'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<String>>(
        future: fetchImageUrls(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Eroare: ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nu există imagini.'));
          }
          final imageUrls = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final url = imageUrls[index];
              return AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            InteractiveViewer(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Image.network(
                                  Uri.encodeFull(url),
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 64,
                                                  color: Colors.white)),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                radius: 22,
                                child:  Icon(Icons.download,
                                    color: Colors.white, size: 24),
                              ),
                              tooltip: 'Descarcă',
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                if (!kIsWeb &&
                                    (Theme.of(context).platform == TargetPlatform.android ||
                                     Theme.of(context).platform == TargetPlatform.iOS)) {
                                  try {
                                    await ImageDownloader.downloadImage(url);
                                    messenger.showSnackBar(
                                      const SnackBar(content: Text('Imagine descărcată cu succes!')),
                                    );
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(content: Text('Eroare la descărcare: $e')),
                                    );
                                  }
                                } else {
                                  // ignore: undefined_prefixed_name
                                  html.window.open(url, '_blank');
                                }
                              },
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: IconButton(
                                icon: const CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  radius: 22,
                                  child:  Icon(Icons.close,
                                      color: Colors.white, size: 24),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Image.network(
                        Uri.encodeFull(url),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.broken_image, size: 48)),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
