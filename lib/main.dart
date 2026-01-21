import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

// -----------------------------------------------------------------------------
// CONFIGURAȚIE & TEMĂ
// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ziarul de Nuntă',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A1A), // Negru
          background: const Color(0xFFFDFBF7), // Crem/Hârtie
        ),
        textTheme: GoogleFonts.playfairDisplayTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDFBF7),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const NewspaperLayout(),
    );
  }
}

// -----------------------------------------------------------------------------
// LAYOUT PRINCIPAL
// -----------------------------------------------------------------------------
class NewspaperLayout extends StatelessWidget {
  const NewspaperLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NewspaperHeader(),
              SizedBox(height: 30),
              HeroSection(),
              SectionDivider(),
              CountdownSection(targetDateStr: "2026-09-12 14:00:00"),

              SizedBox(height: 30),
              // --- SECȚIUNEA INTERACTIVĂ (Upload & Galerie) ---
              MemoriesSection(),

              SectionDivider(),
              // --- SECȚIUNEA LOCAȚII (Refăcută) ---
              LocationsSection(),
              SectionDivider(),

              TimelineSection(),
              SizedBox(height: 30),
              DressCodeSection(),
              SizedBox(height: 40),
              RSVPCard(),
              SizedBox(height: 60),
              NewspaperFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTIUNEA LOCATII (DESIGN PREMIUM)
// -----------------------------------------------------------------------------
class LocationsSection extends StatelessWidget {
  const LocationsSection({super.key});

  Future<void> _launchMap(String query) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Nu s-a putut deschide harta pentru $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('LOCAȚII IMPORTANTE',
            style: GoogleFonts.unifrakturMaguntia(
                fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),

        // Locația 1
        _buildLocationTicket(
          context,
          type: 'CEREMONIE',
          title: 'Cununia Religioasă',
          name: 'Biserica Sf. Ștefan',
          address: 'Bulevardul Chimiei, Iași',
          time: 'ORA 16:00',
          icon: Icons.church,
        ),

        const SizedBox(height: 24),

        // Locația 2
        _buildLocationTicket(
          context,
          type: 'RECEPȚIE',
          title: 'Petrecerea',
          name: 'Liria Events',
          address: 'Lacul Aroneanu, Iași',
          time: 'ORA 20:00',
          icon: Icons.celebration,
        ),
      ],
    );
  }

  Widget _buildLocationTicket(BuildContext context,
      {required String type,
      required String title,
      required String name,
      required String address,
      required String time,
      required IconData icon}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(4, 4),
            blurRadius: 0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Tichet
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.black87, width: 1)),
              color: Color(0xFFF5F5F5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(type,
                    style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold, letterSpacing: 2)),
                Icon(icon, size: 18),
              ],
            ),
          ),

          // Body Tichet
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(address,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[800])),
                const SizedBox(height: 16),
                const Divider(color: Colors.black26, indent: 40, endIndent: 40),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: Text(time,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () => _launchMap("$name, $address"),
                      icon: const Icon(Icons.directions,
                          size: 18, color: Colors.black),
                      label: const Text('NAVIGHEAZĂ',
                          style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PAGINA UPLOAD (LOGICA TA + DESIGN NOU)
// -----------------------------------------------------------------------------
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  // Variabile din codul tau original
  List<File> _selectedImages = [];
  List<Uint8List> _webImages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isUploading = false;

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
    // URL-ul tau original
    final uri = Uri.parse(const String.fromEnvironment('UPLOAD_URL',
        defaultValue: 'https://YOUR_API_GATEWAY_ENDPOINT/upload'));

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        for (int i = 0; i < _webImages.length; i++) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'files',
              _webImages[i],
              filename: 'image_$i.jpg',
            ),
          );
        }
      } else {
        for (int i = 0; i < _selectedImages.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'files',
              _selectedImages[i].path,
              filename: 'image_$i.jpg',
            ),
          );
        }
      }

      final response = await request.send();

      setState(() => _isUploading = false);

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
      setState(() => _isUploading = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Eroare: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = _selectedImages.isNotEmpty || _webImages.isNotEmpty;
    int imageCount = kIsWeb ? _webImages.length : _selectedImages.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Redacția Foto',
            style: GoogleFonts.unifrakturMaguntia(fontSize: 24)),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Ați surprins un moment special?',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Încărcați fotografiile aici pentru a le imortaliza în ediția noastră specială.',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),

              // Buton de selectie
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.folder_open, color: Colors.black),
                label: const Text('SELECTEAZĂ FOTOGRAFII',
                    style: TextStyle(color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),

              const SizedBox(height: 20),

              // Lista de preview (Stil Ziar + Funcționalitatea ta veche)
              if (hasImages) ...[
                SizedBox(
                  height: 120,
                  child: Listener(
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        final newOffset = _scrollController.offset +
                            pointerSignal.scrollDelta.dy;
                        _scrollController.jumpTo(newOffset.clamp(
                            0.0, _scrollController.position.maxScrollExtent));
                      }
                    },
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: imageCount,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            child: kIsWeb
                                ? Image.memory(_webImages[index],
                                    width: 100, height: 100, fit: BoxFit.cover)
                                : Image.file(_selectedImages[index],
                                    width: 100, height: 100, fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isUploading)
                  const CircularProgressIndicator(color: Colors.black)
                else
                  ElevatedButton.icon(
                    onPressed: _submitImages,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text('TRIMITE LA REDACȚIE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                  ),
              ] else ...[
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey[300]!, style: BorderStyle.solid),
                  ),
                  child: Text("Nicio fotografie selectată",
                      style: GoogleFonts.playfairDisplay(color: Colors.grey)),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PAGINA GALERIE (LOGICA TA + DESIGN NOU)
// -----------------------------------------------------------------------------
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  // Logica ta originală de parsare
  Future<List<String>> fetchImageUrls() async {
    const apiUrl = String.fromEnvironment('GALLERY_URL',
        defaultValue: 'https://YOUR_API_GATEWAY_ENDPOINT/gallery');

    // Fallback pentru demo daca nu e setat ENV
    if (apiUrl.contains("YOUR_API_GATEWAY")) {
      // Putem returna o listă goală sau demo, dar pentru a respecta logica ta strict:
      // incercam request-ul, va da eroare 404/host not found si va fi prins in UI
    }

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data['images'] is List) {
        return List<String>.from(data['images']);
      }
      if (data is List) {
        return data.cast<String>();
      }
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

  // Logica de download (Web safe + Mobile)
  // Înlocuiește complet metoda _downloadImage din GalleryPage cu aceasta:
  Future<void> _downloadImage(BuildContext context, String url) async {
    try {
      // 1. Descarcăm imaginea ca bytes indiferent de platformă
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw 'Eroare la descărcare';

      // 2. Convertim în Base64
      final content = base64Encode(response.bodyBytes);

      // 3. Creăm URL-ul de tip data scheme (octet-stream forțează descărcarea)
      final downloadUrl = 'data:application/octet-stream;base64,$content';

      // 4. Lansăm URL-ul în browserul extern
      // Pe Android, browserul va recunoaște header-ul de stream și va porni download-ul
      await launchUrl(
        Uri.parse(downloadUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("Eroare download: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eroare la procesarea imaginii.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeria Oficială',
            style: GoogleFonts.unifrakturMaguntia(fontSize: 24)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: fetchImageUrls(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Eroare: ${snapshot.error}',
                    style: GoogleFonts.playfairDisplay()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('Nu există imagini.',
                    style: GoogleFonts.playfairDisplay()));
          }

          final imageUrls = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final url = imageUrls[index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(10),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          // Adăugăm un Container cu constrângeri pentru a limita mărimea pe Web
                          Container(
                            constraints: BoxConstraints(
                              // Limitează înălțimea la 80% din ecran pentru a nu fi foarte lungi
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                              // Limitează lățimea pe desktop
                              maxWidth: 800,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize
                                  .min, // Forțează coloana să fie cât conținutul
                              children: [
                                Expanded(
                                  child: Image.network(
                                    url,
                                    fit: BoxFit
                                        .contain, // Asigură că imaginea nu se taie
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: () => _downloadImage(context, url),
                                  icon: const Icon(Icons.download,
                                      size: 16, color: Colors.white),
                                  label: const Text("DESCARCĂ"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: const BeveledRectangleBorder(
                                        borderRadius: BorderRadius.zero),
                                  ),
                                )
                              ],
                            ),
                          ),
                          // Butonul de închidere poziționat peste container
                          Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton(
                              icon: const CircleAvatar(
                                backgroundColor: Colors.black,
                                child: Icon(Icons.close,
                                    color: Colors.white, size: 20),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, offset: Offset(3, 3))
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey[100],
                          child: Image.network(url,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) =>
                                  const Icon(Icons.broken_image)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Foto ${index + 1}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey)),
                    ],
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

// -----------------------------------------------------------------------------
// SECȚIUNEA "AMINTIRI" - LINK CĂTRE CELE DE MAI SUS
// -----------------------------------------------------------------------------
class MemoriesSection extends StatelessWidget {
  const MemoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: 1),
        color: Colors.white.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Text('COLȚUL AMINTIRILOR',
              style: GoogleFonts.unifrakturMaguntia(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            'Ajutați-ne să colectăm toate momentele frumoase!',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const UploadPage())),
                  icon: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 16),
                  label: const Text('ÎNCARCĂ POZE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GalleryPage())),
                  icon: const Icon(Icons.photo_library,
                      color: Colors.black, size: 16),
                  label: const Text('VEZI GALERIE'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    foregroundColor: Colors.black,
                    shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// RESTUL COMPONENTELOR (Header, Hero, Countdown, Timeline, Footer)
// -----------------------------------------------------------------------------

class NewspaperHeader extends StatelessWidget {
  const NewspaperHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black87, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetaText('IAȘI, ROMÂNIA'),
              _buildMetaText('SÂMBĂTĂ, 12 SEPT, 2026'),
              _buildMetaText('13:00 PM'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ziarul de Nuntă',
          textAlign: TextAlign.center,
          style:
              GoogleFonts.unifrakturMaguntia(fontSize: 48, color: Colors.black),
        ),
        const SizedBox(height: 10),
        Container(
          height: 4,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black, width: 1),
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 14),
            const SizedBox(width: 4),
            _buildMetaText('EDIȚIE SPECIALĂ'),
            const SizedBox(width: 15),
            const CircleAvatar(radius: 3, backgroundColor: Colors.black),
            const SizedBox(width: 15),
            const Icon(Icons.favorite, size: 14),
            const SizedBox(width: 4),
            _buildMetaText('VOLUMUL I'),
          ],
        )
      ],
    );
  }

  Widget _buildMetaText(String text) {
    return Text(
      text,
      style: GoogleFonts.playfairDisplay(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.black87),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('CEA MAI FRUMOASĂ ZI DIN VIAȚA LOR',
            style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.grey[700])),
        const SizedBox(height: 5),
        const Divider(indent: 100, endIndent: 100, color: Colors.grey),
        const SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.playfairDisplay(
                color: Colors.black, fontSize: 42, height: 1.0),
            children: [
              const TextSpan(text: 'Andreea '),
              TextSpan(
                  text: '&',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey)),
              const TextSpan(text: ' Adelin'),
            ],
          ),
        ),
        Text('SE CĂSĂTORESC!',
            style: GoogleFonts.unifrakturMaguntia(
                fontSize: 24, letterSpacing: 2.0)),
        const SizedBox(height: 30),
        Transform.rotate(
          angle: -0.02,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black87, width: 1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(2, 4))
                ]),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!)),
                  padding: const EdgeInsets.all(4),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=2070&auto=format&fit=crop',
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Fotografie de logodnă, 2025',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600]))
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CountdownSection extends StatefulWidget {
  final String targetDateStr;
  const CountdownSection({super.key, required this.targetDateStr});
  @override
  State<CountdownSection> createState() => _CountdownSectionState();
}

class _CountdownSectionState extends State<CountdownSection> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => _calculateTime());
  }

  void _calculateTime() {
    final target = DateTime.parse(widget.targetDateStr);
    final now = DateTime.now();
    setState(() => _timeLeft = target.difference(now));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeItem(_timeLeft.inDays, 'ZILE'),
          _buildTimeItem(_timeLeft.inHours % 24, 'ORE'),
          _buildTimeItem(_timeLeft.inMinutes % 60, 'MIN'),
          _buildTimeItem(_timeLeft.inSeconds % 60, 'SEC'),
        ],
      ),
    );
  }

  Widget _buildTimeItem(int value, String label) {
    return Column(
      children: [
        Text(value.toString().padLeft(2, '0'),
            style: GoogleFonts.playfairDisplay(
                fontSize: 32, fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.playfairDisplay(
                fontSize: 10, letterSpacing: 1.5, color: Colors.grey[600])),
      ],
    );
  }
}

class TimelineSection extends StatelessWidget {
  const TimelineSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('PROGRAMUL NUNȚII',
            style: GoogleFonts.unifrakturMaguntia(
                fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey, width: 1))),
          child: Column(
            children: [
              _buildEvent(
                  '13:00', 'Cununia Civilă', 'Liria Events', Icons.restaurant),
              _buildEvent(
                  '14:00', 'Cocktail Hour', 'Grădina de Vară', Icons.local_bar),
              _buildEvent('16:00', 'Cununia Religioasă', 'Bis. Sf. Ștefan',
                  Icons.church),
              _buildEvent(
                  '20:00', 'Petrecerea', 'Liria Events', Icons.music_note),
              _buildEvent('21:30', 'Dansul Mirilor', 'Ringul de Dans',
                  Icons.nightlight_round),
              _buildEvent('01:00', 'Tortul Mirilor', 'Terasă', Icons.cake),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildEvent(String time, String title, String loc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              Text(loc,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}

class DressCodeSection extends StatelessWidget {
  const DressCodeSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!), color: Colors.white54),
      child: Column(
        children: [
          const Icon(Icons.checkroom, size: 30),
          const SizedBox(height: 10),
          Text('DRESS CODE',
              style: GoogleFonts.unifrakturMaguntia(fontSize: 20)),
          Text('Black Tie Optional',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorDot(const Color(0xFFF3E5DC)),
              _colorDot(const Color(0xFFD4C5B0)),
              _colorDot(const Color(0xFF1A1A1A)),
              _colorDot(const Color(0xFF5D5C61)),
            ],
          )
        ],
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!)),
    );
  }
}

class RSVPCard extends StatelessWidget {
  const RSVPCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, right: 10),
          padding: const EdgeInsets.all(24),
          color: Colors.grey[100],
          child: Column(
            children: [
              Text('Confirmati Prezenta',
                  style: GoogleFonts.unifrakturMaguntia(fontSize: 28)),
              Text(
                  'Vă rugăm să ne confirmați prezența până la data de 20 Iulie 2026',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                      fontStyle: FontStyle.italic, color: Colors.grey[700])),
              const SizedBox(height: 20),
              _buildInput('Nume Prenume'),
              const SizedBox(height: 12),
              Row(children: [
                Radio(value: true, groupValue: true, onChanged: (v) {}),
                Text('Vom participa', style: GoogleFonts.playfairDisplay())
              ]),
              Row(children: [
                Radio(value: false, groupValue: true, onChanged: (v) {}),
                Text('Nu putem ajunge', style: GoogleFonts.playfairDisplay())
              ]),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send, size: 16, color: Colors.white),
                label: const Text('TRIMITE CONFIRMAREA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.playfairDisplay(
                      letterSpacing: 1.5, fontSize: 12),
                  // FIX CRITIC PENTRU WEB (impiedica crash):
                  shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Transform.rotate(
            angle: 0.2,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
              child: Text('RSVP',
                  style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildInput(String hint) {
    return TextField(
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: GoogleFonts.playfairDisplay(color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
      ),
    );
  }
}

class NewspaperFooter extends StatelessWidget {
  const NewspaperFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 3))),
      child: Center(
        child: Column(
          children: [
            Container(
                height: 1,
                width: 100,
                color: Colors.black,
                margin: const EdgeInsets.only(bottom: 10)),
            Text('Vă așteptăm cu drag!',
                style:
                    GoogleFonts.playfairDisplay(fontStyle: FontStyle.italic)),
            Text('Andreea & Adelin',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Divider(color: Colors.black87, thickness: 1),
    );
  }
}
