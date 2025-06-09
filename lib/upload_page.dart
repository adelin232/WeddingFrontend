import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nunta_aa/wedding_background.dart';
import 'package:http/http.dart' as http;

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<File> _selectedImages = [];
  List<Uint8List> _webImages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    if (kIsWeb) {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final images = <Uint8List>[];
        for (final file in pickedFiles) {
          images.add(await file.readAsBytes());
        }
        setState(() {
          _webImages = images;
          _selectedImages = [];
        });
      }
    } else {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages = pickedFiles.map((e) => File(e.path)).toList();
          _webImages = [];
        });
      }
    }
  }

  Future<void> _submitImages() async {
    final uri = Uri.parse(const String.fromEnvironment('UPLOAD_URL',
        defaultValue: 'https://YOUR_API_GATEWAY_ENDPOINT/upload'));
    final messenger = ScaffoldMessenger.of(context);
    try {
      var request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        for (int i = 0; i < _webImages.length; i++) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'files',
              _webImages[i],
              filename: 'photographs/image_$i.jpg',
            ),
          );
        }
      } else {
        for (int i = 0; i < _selectedImages.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'files',
              _selectedImages[i].path,
              filename: 'photographs/image_$i.jpg',
            ),
          );
        }
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Imaginile au fost trimise cu succes!')),
        );
        setState(() {
          _selectedImages.clear();
          _webImages.clear();
        });
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('Eroare la upload: ${response.statusCode}')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Eroare: $e')),
      );
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
        title: const Text('Încarcă Fotografii'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: WeddingBackground(
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: Colors.white.withOpacity(0.85),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Încarcă pozele aici',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.upload),
                    label: const Text('Selectează fotografii'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedImages.isNotEmpty || _webImages.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      width: 340,
                      child: Listener(
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            final newOffset = _scrollController.offset +
                                pointerSignal.scrollDelta.dy;
                            _scrollController.jumpTo(
                              newOffset.clamp(
                                0.0,
                                _scrollController.position.maxScrollExtent,
                              ),
                            );
                          }
                        },
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: kIsWeb
                                ? _webImages.length
                                : _selectedImages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: kIsWeb
                                    ? Image.memory(
                                        _webImages[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.contain,
                                      )
                                    : Image.file(
                                        _selectedImages[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.contain,
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _submitImages,
                      icon: const Icon(Icons.send),
                      label: const Text('Trimite'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
