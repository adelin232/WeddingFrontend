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
import 'map_helper_stub.dart' if (dart.library.html) 'map_helper_web.dart';
import 'package:path_provider/path_provider.dart'; // Pentru a gasi calea pe mobil
import 'package:share_plus/share_plus.dart'; // Pentru a salva/partaja pe mobil

// Import condiționat: încarcă helper-ul de web DOAR dacă e web
import 'stub_download_helper.dart'
    if (dart.library.html) 'web_download_helper.dart';

void setupMape() {
  // 1. Ceremonia Religioasă - Biserica Cuvioasa Parascheva
  registerWebMap('map-biserica',
      'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2802.266091664396!2d27.035552386773457!3d45.38380289648595!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x40b1556e31b7bfb3%3A0x8775a6c3cc9a9399!2sBiserica%20Cuvioasa%20Parascheva!5e0!3m2!1sro!2sro!4v1773585186168!5m2!1sro!2sro');

  // 2. Petrecerea - Avo GastroHan
  registerWebMap('map-petrecere',
      'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2802.720173419411!2d27.02906007614609!3d45.37464147107268!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x40b1559d8c478857%3A0x480d1008d5447391!2sAvo%20GastroHan!5e0!3m2!1sro!2sro!4v1768991399344!5m2!1sro!2sro');
}

void main() {
  if (kIsWeb) {
    setupMape();
  }
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
          seedColor: const Color(0xFF1A1A1A),
          background: const Color(0xFFFDFBF7),
        ),
        // Playfair Display oferă acel aspect de ziar clasic, dar este mult mai clar
        textTheme: GoogleFonts.playfairDisplayTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          bodyMedium: GoogleFonts.lora(
              fontSize: 16), // Lora este excelent pentru citit texte lungi
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          // Centram pe orizontala
          child: Container(
            constraints:
                const BoxConstraints(maxWidth: 1000), // Latime optima de citit
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              boxShadow: kIsWeb
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ]
                  : [],
            ),
            child: const SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NewspaperHeader(),
                  SizedBox(height: 30),
                  HeroSection(),
                  SectionDivider(),
                  CountdownSection(targetDateStr: "2026-09-12 17:00:00"),
                  SizedBox(height: 30),
                  SectionDivider(),
                  MemoriesSection(),
                  SectionDivider(),
                  LocationsSection(),
                  SectionDivider(),
                  TimelineSection(), // Sectiunea noua alternativa
                  SizedBox(height: 40),
                  RSVPCard(),
                  SizedBox(height: 60),
                  NewspaperFooter(),
                ],
              ),
            ),
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
            style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 40),

        // 1. CEREMONIA RELIGIOASĂ
        _buildLocationTicket(
          context,
          type: 'CEREMONIA RELIGIOASĂ',
          name: 'Biserica Cuvioasa Parascheva',
          address: 'Strada Patriei, Râmnicu Sărat',
          time: 'ORA 17:00',
          icon: Icons.church_rounded,
          viewId: 'map-biserica',
        ),

        const SizedBox(height: 30),

        // 2. PETRECEREA
        _buildLocationTicket(
          context,
          type: 'PETRECEREA',
          name: 'Avo GastroHan',
          address: 'Strada Stadionului 10, Râmnicu Sărat',
          time: 'ORA 18:30',
          icon: Icons.celebration_rounded,
          viewId: 'map-petrecere',
        ),
      ],
    );
  }

  Widget _buildLocationTicket(BuildContext context,
      {required String type,
      required String name,
      required String address,
      required String time,
      required IconData icon,
      required String viewId}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(4, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(type,
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                Icon(icon, color: Colors.white, size: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black)),
                const SizedBox(height: 6),
                Text(address,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87)),
                const SizedBox(height: 20),

                // Zona Hărții Embedded folosind src-ul din iframe-ul tău
                Container(
                  height: 300, // Înălțime mărită pentru vizibilitate mai bună
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300)),
                  child: kIsWeb
                      ? HtmlElementView(viewType: viewId)
                      : Center(
                          child: TextButton.icon(
                              onPressed: () => _launchMap("$name, $address"),
                              icon: const Icon(Icons.map),
                              label: const Text("DESCHIDE HARTA"))),
                ),

                const SizedBox(height: 20),
                Text(time,
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1)),
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
        title: Text('Redacția Foto', style: GoogleFonts.lora(fontSize: 24)),
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
  Future<void> _downloadImage(BuildContext context, String url) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Se încearcă descărcarea...'),
            duration: Duration(seconds: 1)),
      );

      // Truc: Adăugăm un parametru de timp pentru a forța browserul să nu folosească o versiune veche (fără drepturi) din cache
      final String cacheBusterUrl = url.contains('?')
          ? '$url&t=${DateTime.now().millisecondsSinceEpoch}'
          : '$url?t=${DateTime.now().millisecondsSinceEpoch}';

      // Încercăm să descărcăm datele pentru a le redenumi
      final response = await http.get(Uri.parse(cacheBusterUrl));

      if (response.statusCode == 200) {
        // SUCCES: Putem pune numele dorit
        final Uint8List bytes = response.bodyBytes;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final String fileName = "nunta_andreea_adelin_$timestamp.jpg";

        if (kIsWeb) {
          downloadWeb(bytes, fileName);
        } else {
          // Logica pentru aplicație nativă (dacă vei face APK vreodată)
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          await Share.shareXFiles([XFile(file.path)], text: 'Amintire Nuntă');
        }
      } else {
        throw 'Serverul a refuzat conexiunea.';
      }
    } catch (e) {
      debugPrint("Eroare download inteligent ($e). Se trece la Planul B.");

      // PLAN B: Dacă http.get eșuează (CORS), deschidem link-ul direct.
      // Utilizatorul va vedea poza și o poate salva cu "Long Press" -> "Save Image"
      try {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode
              .externalApplication, // Deschide în tab nou / aplicație externă
        );
      } catch (e2) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nu s-a putut deschide imaginea.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeria Oficială', style: GoogleFonts.lora(fontSize: 24)),
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
          Text('COLȚUL AMINTIRILOR', style: GoogleFonts.lora(fontSize: 22)),
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
              _buildMetaText('RÂMNICU SĂRAT'),
              _buildMetaText('SÂMBĂTĂ, 12 SEPT, 2026'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ziarul de Nuntă',
          textAlign: TextAlign.center,
          style: GoogleFonts.lora(fontSize: 48, color: Colors.black),
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
            /** TODO: sterge */
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
      style: GoogleFonts.montserrat(
        // Schimbat în Montserrat
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.black87,
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});
  @override
  Widget build(BuildContext context) {
    const photoUrl = String.fromEnvironment('PHOTO_URL',
        defaultValue: 'https://YOUR_PHOTO_URL/photo');
    return Column(
      children: [
        Text('CEA MAI SPECIALĂ ZI',
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
                      color: Colors.black)),
              const TextSpan(text: ' Adelin'),
            ],
          ),
        ),
        // În HeroSection
        Text(
          'SE CĂSĂTORESC!',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 6.0, // Spațiere mare pentru eleganță
            fontStyle: FontStyle.italic,
          ),
        ),
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
                  child: Image.network(
                    photoUrl,
                    // TODO: mai taie poza de jos in sus
                    height: 600,
                    width: 600,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Balul de 8 martie 2026',
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
        Text(
          value.toString().padLeft(2, '0'),
          style: GoogleFonts.playfairDisplay(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class TimelineSection extends StatelessWidget {
  const TimelineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> events = [
      {
        'time': '17:00',
        'title': 'Cununia Religioasă',
        'loc': 'Biserica Cuv. Parascheva'
      },
      {'time': '18:30', 'title': 'Petrecerea', 'loc': 'Avo GastroHan'},
      {'time': '20:30', 'title': 'Dansul Mirilor', 'loc': 'Ringul de Dans'},
      {'time': '01:00', 'title': 'Tortul Mirilor', 'loc': 'Sala Principală'},
    ];

    return Column(
      children: [
        Text(
          'PROGRAMUL NUNȚII',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            bool isLeft = index % 2 == 0;
            return IntrinsicHeight(
              child: Row(
                children: [
                  // Partea stângă
                  Expanded(
                    child: isLeft
                        ? _buildEventDetail(
                            events[index], CrossAxisAlignment.end,
                            textAlign: TextAlign.right)
                        : const SizedBox(),
                  ),
                  // Linia centrală cu punct
                  Column(
                    children: [
                      Container(width: 1, color: Colors.black38, height: 20),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                          color: const Color(0xFFFDFBF7),
                        ),
                        child: const CircleAvatar(
                            radius: 3, backgroundColor: Colors.black),
                      ),
                      Expanded(
                          child: Container(width: 1, color: Colors.black38)),
                    ],
                  ),
                  // Partea dreaptă
                  Expanded(
                    child: !isLeft
                        ? _buildEventDetail(
                            events[index], CrossAxisAlignment.start,
                            textAlign: TextAlign.left)
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventDetail(
      Map<String, String> event, CrossAxisAlignment alignment,
      {required TextAlign textAlign}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            event['time']!,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
          ),
          Text(
            event['title']!,
            textAlign: textAlign,
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            event['loc']!,
            style: GoogleFonts.lora(
                fontStyle: FontStyle.italic,
                fontSize: 13,
                color: Colors.black54),
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
          Text(
            'DRESS CODE',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          Text(
            'Black Tie Optional',
            style: GoogleFonts.montserrat(
              // Montserrat pentru claritate maximă
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
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

class RSVPCard extends StatefulWidget {
  const RSVPCard({super.key});

  @override
  State<RSVPCard> createState() => _RSVPCardState();
}

class _RSVPCardState extends State<RSVPCard> {
  bool? _isComing;
  int _nrMeniuClasic = 0;
  int _nrMeniuVegetarian = 0;
  final TextEditingController _numeController = TextEditingController();
  bool _isLoading = false;

  // URL-ul tau de la Google Apps Script
  final String _scriptUrl =
      "https://script.google.com/macros/s/AKfycbzDf9Hem_sn5ghWNiYRVfdfnHErS9ibub_qwAQ7LEWr3dbWY9eENbtI-A8ywQQDuIiv/exec";

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.lora()),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _trimiteConfirmarea() async {
    if (_numeController.text.trim().isEmpty) {
      _showSnackBar('Vă rugăm să introduceți numele!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(_scriptUrl),
        body: json.encode({
          "nume": _numeController.text.trim(),
          "prezenta": _isComing,
          "meniuClasic": _isComing == true ? _nrMeniuClasic : 0,
          "meniuVegetarian": _isComing == true ? _nrMeniuVegetarian : 0,
          "totalPersoane":
              _isComing == true ? (_nrMeniuClasic + _nrMeniuVegetarian) : 0,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        _showSnackBar('Confirmarea a fost salvată! Vă mulțumim!');
        _numeController.clear();
        setState(() {
          _isComing = null;
          _nrMeniuClasic = 0;
          _nrMeniuVegetarian = 0;
          _isLoading = false;
        });
      } else {
        throw "Eroare server (${response.statusCode})";
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Eroare la trimitere: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Validare: Butonul e activ daca (au zis NU) SAU (au zis DA si au minim 1 meniu selectat)
    bool isFormValid = _isComing == false ||
        (_isComing == true && (_nrMeniuClasic + _nrMeniuVegetarian) > 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(4, 4))
        ],
      ),
      child: Column(
        children: [
          // Header Negru RSVP
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.black,
            child: Text(
              'RSVP',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                fontSize: 14,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  'CONFIRMAȚI PREZENȚA',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vă rugăm să ne răspundeți până la 20 iulie 2026',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                      fontStyle: FontStyle.italic, color: Colors.black54),
                ),
                const SizedBox(height: 30),

                // INPUT NUME
                TextField(
                  controller: _numeController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: 'Cine ne onorează cu prezența?',
                    hintText: 'Ex: Familia Popescu / Maria și Ion',
                    labelStyle: GoogleFonts.playfairDisplay(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black, width: 1.5)),
                  ),
                ),

                const SizedBox(height: 24),

                // INTREBARE PARTICIPARE
                Text('Veți fi alături de noi?',
                    style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),

                _buildRadioOption('Da, abia așteptăm!', true),
                _buildRadioOption('Din păcate, nu putem ajunge', false),

                // SECTIUNE MENIURI (Apare doar daca _isComing == true)
                if (_isComing == true) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('CONFIGURARE MENIURI',
                      style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1)),
                  const SizedBox(height: 20),
                  _buildMenuRow("Meniu Clasic", _nrMeniuClasic, (val) {
                    setState(() => _nrMeniuClasic = val!);
                  }),
                  const SizedBox(height: 12),
                  _buildMenuRow("Meniu Vegetarian", _nrMeniuVegetarian, (val) {
                    setState(() => _nrMeniuVegetarian = val!);
                  }),
                  if (_nrMeniuClasic + _nrMeniuVegetarian == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text('* Selectați cel puțin un meniu',
                          style: GoogleFonts.lora(
                              color: Colors.red[700], fontSize: 12)),
                    ),
                ],

                const SizedBox(height: 40),

                // BUTON TRIMITE
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (_isComing == null || !isFormValid)
                              ? null
                              : _trimiteConfirmarea,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                          ),
                          child: Text(
                            'TRIMITE CONFIRMAREA',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pentru optiunile Radio
  Widget _buildRadioOption(String title, bool value) {
    return InkWell(
      onTap: () => setState(() => _isComing = value),
      child: Row(
        children: [
          Radio<bool>(
            value: value,
            groupValue: _isComing,
            activeColor: Colors.black,
            onChanged: (v) => setState(() => _isComing = v),
          ),
          Text(title, style: GoogleFonts.lora(fontSize: 15)),
        ],
      ),
    );
  }

  // Widget pentru randurile de meniu cu Dropdown
  Widget _buildMenuRow(
      String label, int currentValue, Function(int?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.lora(fontSize: 16)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
          ),
          child: DropdownButton<int>(
            value: currentValue,
            underline: const SizedBox(),
            items: List.generate(11, (index) => index)
                .map((i) => DropdownMenuItem<int>(
                      value: i,
                      child:
                          Text(i.toString(), style: GoogleFonts.montserrat()),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
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
