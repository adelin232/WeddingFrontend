import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'map_helper_stub.dart' if (dart.library.html) 'map_helper_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';

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
      title: 'Ziarul de Nunta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(0xFFEFECE5), // Fundal tip pergament
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A1A1A)),
        textTheme:
            GoogleFonts.playfairDisplayTextTheme(Theme.of(context).textTheme)
                .copyWith(
          bodyMedium: GoogleFonts.lora(fontSize: 15, color: Colors.black87),
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
        body: Container(
      // AICI SETĂM IMAGINEA DE FUNDAL PENTRU TOT ECRANUL
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage("assets/images/newspaper_bkg.png"),
          fit: BoxFit.cover, // Imaginea acoperă tot ecranul
          // OPȚIONAL: Dacă imaginea e prea puternică, îi punem o mască albă/crem peste ea
          colorFilter: ColorFilter.mode(
            const Color(0xFFEFECE5).withOpacity(
                0.85), // 0.85 înseamnă 85% opacitate (15% transparență)
            BlendMode.lighten,
          ),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE5), // Culoarea hartiei
              border:
                  kIsWeb ? Border.all(color: Colors.black87, width: 1) : null,
              boxShadow: kIsWeb
                  ? [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2)
                    ]
                  : [],
            ),
            margin: kIsWeb
                ? const EdgeInsets.symmetric(vertical: 20)
                : EdgeInsets.zero,
            child: const SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  NewspaperHeader(),
                  SizedBox(height: 30),
                  HeroSection(),
                  DoubleLineDivider(),
                  CountdownSection(targetDateStr: "2026-09-12 17:00:00"),
                  DoubleLineDivider(),
                  // FamilyAndProgramSection(), // Structura noua pe coloane
                  // DoubleLineDivider(),
                  // LoveStorySection(),
                  TimelineSection(),
                  DoubleLineDivider(),
                  LocationsSection(),
                  DoubleLineDivider(),
                  MemoriesSection(),
                  DoubleLineDivider(),
                  RSVPCard(),
                  SizedBox(height: 40),
                  BottomActionSection(),
                  SizedBox(height: 40),
                  NewspaperFooter(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

// -----------------------------------------------------------------------------
// COMPONENTE DE DESIGN (Ziar)
// -----------------------------------------------------------------------------
class DoubleLineDivider extends StatelessWidget {
  const DoubleLineDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Column(
        children: [
          Container(height: 2, color: Colors.black87),
          const SizedBox(height: 3),
          Container(height: 1, color: Colors.black87),
        ],
      ),
    );
  }
}

class NewspaperHeader extends StatelessWidget {
  const NewspaperHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Ziarul De Nunta',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily:
                'Brookshire', // Numele EXACT din pubspec.yaml (la "family:")
            fontSize: 44,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(height: 2, color: Colors.black),
        const SizedBox(height: 4),
        Container(height: 1, color: Colors.black),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RÂMNICU SĂRAT',
                style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            Text('12 SEPT. 2026',
                style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: Colors.black),
        const SizedBox(height: 4),
        Container(height: 2, color: Colors.black),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// HERO SECTION
// -----------------------------------------------------------------------------
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});
  @override
  Widget build(BuildContext context) {
    const photoUrl = String.fromEnvironment('PHOTO_URL',
        defaultValue:
            'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=2070&auto=format&fit=crop');

    return Column(
      children: [
        Text('CEA MAI SPECIALĂ ZI',
            style: GoogleFonts.cinzel(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.grey[800])),
        const SizedBox(height: 5),
        Container(width: 350, height: 1, color: Colors.black87),
        const SizedBox(height: 5),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.playfairDisplay(
                color: Colors.black,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                height: 1.0),
            children: [
              const TextSpan(text: 'Andreea '),
              TextSpan(
                  text: '&',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54)),
              const TextSpan(text: ' Adelin'),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'SE CĂSĂTORESC!',
          style: GoogleFonts.cinzel(
              fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 4.0),
        ),
        const SizedBox(height: 30),
        Transform.rotate(
          angle: -0.01,
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black87, width: 1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(4, 4))
                ]),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!)),
                  padding: const EdgeInsets.all(4),
                  child: Image.network(photoUrl,
                      height: 600, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 8),
                Text('Serată la Castelul Cantacuzino, Martie 2026',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600]),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text('„Dragostea este poezia simțurilor.”\n- Honoré de Balzac',
            textAlign: TextAlign.center,
            style: GoogleFonts.greatVibes(fontSize: 28)),
        const SizedBox(height: 20),
        // Text(
        //   'Vă invităm să fiți alături de noi când vom rosti legămintele de dragoste. Ne-ar face o deosebită plăcere să sărbătorim împreună acest moment special din viața noastră.',
        //   textAlign: TextAlign.center,
        //   style: GoogleFonts.lora(fontSize: 16, height: 1.6, fontStyle: FontStyle.italic),
        // ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// COUNTDOWN
// -----------------------------------------------------------------------------
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
          style: GoogleFonts.cinzel(
              fontSize: 42, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800]),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// FAMILIE & PROGRAM (LAYOUT COLOANE)
// -----------------------------------------------------------------------------
class FamilyAndProgramSection extends StatelessWidget {
  const FamilyAndProgramSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 650) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(child: _buildFamily()),
            Container(
                width: 1,
                color: Colors.black26,
                height: 400,
                margin: const EdgeInsets.symmetric(horizontal: 20)),
            const Expanded(child: TimelineSection()),
          ],
        );
      } else {
        return const Column(
          children: [
            // _buildFamily(),
            // const DoubleLineDivider(),
            TimelineSection(),
          ],
        );
      }
    });
  }

  // Widget _buildFamily() {
  //   return Column(
  //     children: [
  //       Text('ALĂTURI DE EI', style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold)),
  //       const SizedBox(height: 30),
  //       _familyGroup('NAȘII', 'Georgiana & Alexandru\nDUMITRESCU'),
  //       const SizedBox(height: 24),
  //       _familyGroup('PĂRINȚII MIRELUI', 'Mirela LĂȚEA &\nCristian MIULEȚ'),
  //       const SizedBox(height: 24),
  //       _familyGroup('PĂRINȚII MIRESEI', 'Otilia &\nAndrei PROCA'),
  //     ],
  //   );
  // }

//   Widget _familyGroup(String role, String names) {
//     return Column(
//       children: [
//         Text(role,
//             style: GoogleFonts.montserrat(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 2,
//                 color: Colors.black54)),
//         const SizedBox(height: 8),
//         Text(names,
//             textAlign: TextAlign.center,
//             style: GoogleFonts.playfairDisplay(
//                 fontSize: 18, fontWeight: FontWeight.w600)),
//       ],
//     );
//   }
}

// -----------------------------------------------------------------------------
// TIMELINE (Alternativ)
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// TIMELINE SECTION (ACTUALIZATĂ: SCALARE ȘI CULORI ORIGINALE)
// -----------------------------------------------------------------------------
class TimelineSection extends StatelessWidget {
  const TimelineSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Definirea evenimentelor cu iconițele lor (căi locale PNG din assets)
    final List<Map<String, dynamic>> events = [
      {
        'time': '17:00',
        'title': 'Cununia Religioasă',
        'loc': 'Biserica Cuv. Parascheva',
        'iconPath': 'assets/icons/biserica.png',
        'isDansPhoto': true,
        'isPartyPhoto': false,
      },
      {
        'time': '18:30',
        'title': 'Petrecerea',
        'loc': 'Avo GastroHan',
        'iconPath': 'assets/icons/petrecere.png',
        'isDansPhoto': true,
        'isPartyPhoto': true,
      },
      {
        'time': '20:00',
        'title': 'Dansul Mirilor',
        'loc': 'Ringul de Dans',
        // AICI: Folosește calea corectă către imaginea ta 'dans.png'
        'iconPath': 'assets/icons/dans.png',
        'isDansPhoto': true,
        'isPartyPhoto': false,
      },
      {
        'time': '01:00',
        'title': 'Tortul Mirilor',
        'loc': 'Sala Principală',
        'iconPath': 'assets/icons/tort.png',
        'isDansPhoto': true,
        'isPartyPhoto': false,
      },
    ];

    return Column(
      children: [
        Text(
          'PROGRAMUL NUNȚII',
          style: GoogleFonts.cinzel(
              fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            bool isLeft = index % 2 == 0;
            final event = events[index];

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Aliniem totul pe centru pe orizontală
                children: [
                  // --- COLOANA STÂNGĂ ---
                  Expanded(
                    child: isLeft
                        ? _buildEventText(
                            event, CrossAxisAlignment.end, TextAlign.right)
                        // AICI: Apelăm noua funcție de randare a imaginii/iconiței
                        : _buildEventVisual(
                            event['iconPath'] as String, Alignment.centerRight,
                            isDansPhoto: event['isDansPhoto'] as bool,
                            isPartyPhoto: event['isPartyPhoto'] as bool),
                  ),

                  // --- LINIA CENTRALĂ (Rămâne neschimbată) ---
                  _buildTimelineDivider(),

                  // --- COLOANA DREAPTĂ ---
                  Expanded(
                    child: !isLeft
                        ? _buildEventText(
                            event, CrossAxisAlignment.start, TextAlign.left)
                        // AICI: Apelăm noua funcție de randare a imaginii/iconiței
                        : _buildEventVisual(
                            event['iconPath'] as String, Alignment.centerLeft,
                            isDansPhoto: event['isDansPhoto'] as bool),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // --- WIDGET AJUTĂTOR PENTRU LINIA CENTRALĂ ---
  Widget _buildTimelineDivider() {
    return Column(
      children: [
        Container(width: 1, color: Colors.black38, height: 20),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black),
            color: const Color(0xFFEFECE5), // Fundalul pergament
          ),
          child: const CircleAvatar(radius: 3, backgroundColor: Colors.black),
        ),
        Expanded(child: Container(width: 1, color: Colors.black38)),
      ],
    );
  }

  // --- WIDGET AJUTĂTOR PENTRU TEXT ---
  Widget _buildEventText(Map<String, dynamic> event,
      CrossAxisAlignment alignment, TextAlign textAlign) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: alignment,
        mainAxisAlignment: MainAxisAlignment
            .center, // Centrare pe verticală în dreptul iconiței
        children: [
          Text(event['time'] as String,
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w900, fontSize: 14)),
          Text(event['title'] as String,
              textAlign: textAlign,
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold, fontSize: 18)),
          Text(event['loc'] as String,
              textAlign: textAlign,
              style: GoogleFonts.lora(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: Colors.black54)),
        ],
      ),
    );
  }

  // --- WIDGET AJUTĂTOR PENTRU IMAGINE/ICON (SOLUȚIA PENTRU ERORI) ---
  Widget _buildEventVisual(String assetPath, Alignment alignment,
      {bool isDansPhoto = false, bool isPartyPhoto = false}) {
    double size = isDansPhoto ? 80 : 40;
    double size2 = isPartyPhoto ? 80 : 40;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      // Adăugăm un pic de padding vertical dacă e fotografia mare, ca să nu înghesuie textul
      margin: EdgeInsets.symmetric(vertical: isDansPhoto ? 10 : 0),
      child: Image.asset(
        assetPath,
        width: isPartyPhoto ? size2 : size,
        height: isPartyPhoto ? size2 : size,
        fit: isDansPhoto
            ? BoxFit.contain
            : BoxFit.contain, // contain asigură că se vede toată

        // 2. FĂRĂ FILL CU NEGRU: Dacă e fotografia 'dans.png', setăm color la 'null' (fără tintă)
        // În caz contrar, lăsăm 'Colors.black87' pentru a colora iconițele standard
        color: isDansPhoto ? null : Colors.black87,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// POVESTEA DE DRAGOSTE
// -----------------------------------------------------------------------------
// class LoveStorySection extends StatelessWidget {
//   const LoveStorySection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text('POVESTEA LOR', style: GoogleFonts.cinzel(fontSize: 26, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 20),
//         Text('„Dragostea este poezia simțurilor.”\n- Honoré de Balzac', textAlign: TextAlign.center, style: GoogleFonts.greatVibes(fontSize: 26)),
//         const SizedBox(height: 20),
//         Text(
//           'Totul a început pe 4 decembrie 2022, cu o simplă discuție la facultate. Destinul celor doi s-a legat, însă, definitiv într-un tren spre București. De atunci, fiecare zi a devenit o filă dintr-un roman de dragoste pe care abia așteaptă să îl scrie împreună.',
//           textAlign: TextAlign.center, style: GoogleFonts.lora(fontSize: 16, height: 1.6),
//         ),
//       ],
//     );
//   }
// }

// -----------------------------------------------------------------------------
// LOCATII (Cu Harta Statica pentru Performanta Maxima)
// -----------------------------------------------------------------------------
class LocationsSection extends StatelessWidget {
  const LocationsSection({super.key});

  Future<void> _launchMap(String query) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Nu s-a putut deschide harta');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('LOCAȚII IMPORTANTE',
            textAlign: TextAlign.center,
            style:
                GoogleFonts.cinzel(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        _buildLocationTicket(
          context,
          type: 'CEREMONIA RELIGIOASĂ',
          name: 'Biserica Cuvioasa Parascheva',
          address: 'Strada Patriei, Râmnicu Sărat',
          time: 'ORA 17:00',
          icon: Icons.church_outlined,
          // Calea către screenshot-ul cu harta bisericii
          mapImagePath: 'assets/images/harta_biserica.png',
        ),
        const SizedBox(height: 30),
        _buildLocationTicket(
          context,
          type: 'PETRECEREA',
          name: 'Avo GastroHan',
          address: 'Strada Stadionului 10, Râmnicu Sărat',
          time: 'ORA 18:30',
          icon: Icons.celebration_outlined,
          // Calea către screenshot-ul cu harta restaurantului
          mapImagePath: 'assets/images/harta_restaurant.png',
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
      required String mapImagePath}) {
    // Inlocuit viewId cu mapImagePath
    return Center(
        child: Container(
      constraints: const BoxConstraints(maxWidth: 600),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: const [
            BoxShadow(color: Colors.black12, offset: Offset(4, 4))
          ]),
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
                        fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(address,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                        fontSize: 15, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),

                // Zona Hărții (Imagine statică cu GestureDetector)
                GestureDetector(
                  onTap: () => _launchMap("$name, $address"),
                  child: Container(
                    height: 250, // O inaltime potrivita
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      image: DecorationImage(
                        image: AssetImage(mapImagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Overlay și Buton
                    child: Container(
                      color:
                          Colors.black.withOpacity(0.2), // Întunecare subtilă
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.black87),
                              const SizedBox(width: 8),
                              Text(
                                "VEZI TRASEUL",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
    ));
  }
}

// -----------------------------------------------------------------------------
// UPLOAD SI GALERIE
// -----------------------------------------------------------------------------
class MemoriesSection extends StatelessWidget {
  const MemoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      constraints: const BoxConstraints(maxWidth: 600),
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: 1),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Text('COLȚUL AMINTIRILOR',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            'Ajutați-ne să colectăm toate momentele frumoase surprinse de voi!',
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(fontStyle: FontStyle.italic, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const UploadPage())),
                  icon: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 18),
                  label: const Text('ÎNCARCĂ FOTO'),
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
                      color: Colors.black, size: 18),
                  label: const Text('VEZI GALERIA'),
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
    ));
  }
}

// -----------------------------------------------------------------------------
// RSVP CARD (Stateful cu Dropdown și Câmp de Mesaj)
// -----------------------------------------------------------------------------
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
  final TextEditingController _mesajController =
      TextEditingController(); // <-- NOU: Controller pentru mesaj
  bool _isLoading = false;

  final String _scriptUrl =
      "https://script.google.com/macros/s/AKfycbzoCTBULkrG9blHSyQGkqqbY4JMWt5TcCzRJJabI93vAiGkb-crHtNzj6kNS8k-VmlQ/exec";

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: GoogleFonts.lora()),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating),
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
          "mesaj":
              _mesajController.text.trim(), // <-- NOU: Trimitem și mesajul!
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 302) {
        _showSnackBar('Confirmarea a fost salvată! Vă mulțumim!');
        _numeController.clear();
        _mesajController.clear(); // <-- Curățăm și mesajul după trimitere
        setState(() {
          _isComing = null;
          _nrMeniuClasic = 0;
          _nrMeniuVegetarian = 0;
          _isLoading = false;
        });
      } else {
        throw "Eroare server";
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Eroare la trimitere: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalInvitati = _nrMeniuClasic + _nrMeniuVegetarian;
    bool isFormValid =
        _isComing == false || (_isComing == true && totalInvitati > 0);

    return Center(
        child: Container(
      constraints: const BoxConstraints(maxWidth: 600),
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
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.black,
            child: Text('RSVP',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    fontSize: 14)),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text('CONFIRMAȚI PREZENȚA',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                // const SizedBox(height: 8),
                // Text('Vă rugăm să ne răspundeți până la 12 august 2026',
                //     textAlign: TextAlign.center,
                //     style: GoogleFonts.lora(
                //         fontStyle: FontStyle.italic, color: Colors.black54)),
                const SizedBox(height: 30),

                // --- Câmp Nume ---
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

                // --- Radio Buttons ---
                Text('Veți fi alături de noi?',
                    style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                _buildRadioOption('Da, abia așteptăm!', true),
                _buildRadioOption('Din păcate, nu putem ajunge', false),

                if (_isComing == true) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('CONFIGURARE MENIURI',
                      style: GoogleFonts.cinzel(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1)),
                  const SizedBox(height: 20),
                  _buildMenuRow("Meniu Clasic", _nrMeniuClasic,
                      (val) => setState(() => _nrMeniuClasic = val!)),
                  const SizedBox(height: 12),
                  _buildMenuRow("Meniu Vegetarian", _nrMeniuVegetarian,
                      (val) => setState(() => _nrMeniuVegetarian = val!)),
                  const SizedBox(height: 16),
                  Text(
                    'Total invitați: $totalInvitati',
                    style: GoogleFonts.lora(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600),
                  ),
                  if (totalInvitati == 0)
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('* Selectați cel puțin un meniu',
                            style: GoogleFonts.lora(
                                color: Colors.red, fontSize: 12))),

                  const SizedBox(height: 24),

                  // --- NOU: Câmp Text Multi-linie pentru Mesaj / Cazare ---
                  TextField(
                    controller: _mesajController,
                    cursorColor: Colors.black,
                    maxLines: 3, // Îl facem mai mare, ca un text area
                    decoration: InputDecoration(
                      labelText: 'Mesaj / Alte mențiuni (Opțional)',
                      hintText:
                          'Dacă doriți să ne transmiteți un mesaj, o puteți face aici.',
                      alignLabelWithHint: true, // Aliniază label-ul sus
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
                ],

                const SizedBox(height: 40),
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
                              disabledBackgroundColor: Colors.grey,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero)),
                          child: Text('TRIMITE CONFIRMAREA',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildRadioOption(String title, bool value) {
    return InkWell(
      onTap: () => setState(() => _isComing = value),
      child: Row(children: [
        Radio<bool>(
            value: value,
            groupValue: _isComing,
            activeColor: Colors.black,
            onChanged: (v) => setState(() => _isComing = v)),
        Text(title, style: GoogleFonts.lora(fontSize: 15))
      ]),
    );
  }

  Widget _buildMenuRow(
      String label, int currentValue, Function(int?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
          child: DropdownButton<int>(
            value: currentValue,
            underline: const SizedBox(),
            items: List.generate(11, (index) => index)
                .map((i) => DropdownMenuItem<int>(
                    value: i,
                    child: Text(i.toString(), style: GoogleFonts.montserrat())))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// BOTTOM SECTION (Poezie & Contact)
// -----------------------------------------------------------------------------
class BottomActionSection extends StatelessWidget {
  const BottomActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.mail, color: Colors.black, size: 30),
        // Text('Ce bine că ești\nde Nichita Stănescu', textAlign: TextAlign.center, style: GoogleFonts.greatVibes(fontSize: 26)),
        // const SizedBox(height: 15),
        // Text(
        //   'E o întâmplare a ființei mele:\nși atunci fericirea din lăuntrul meu\ne mai puternică decât mine, decât oasele mele,\npe care mi le scrâșnești într-o îmbrățișare...',
        //   textAlign: TextAlign.center,
        //   style: GoogleFonts.lora(fontStyle: FontStyle.italic, fontSize: 15, height: 1.6),
        // ),
        const SizedBox(height: 20),
        Text('CONTACT',
            style:
                GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('Andreea: +40 752 267 736\nAdelin: +40 747 553 042',
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(fontSize: 16, height: 1.5)),
      ],
    );
  }
}

class NewspaperFooter extends StatelessWidget {
  const NewspaperFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(child: Icon(Icons.filter_vintage, size: 30)),
        const SizedBox(height: 10),
        Text('Vă așteptăm cu drag!',
            style: GoogleFonts.lora(fontStyle: FontStyle.italic, fontSize: 20)),
      ],
    );
  }
}

// =============================================================================
// PAGINILE UPLOAD & GALLERY (Adaptate pentru S3 Pre-signed URLs)
// =============================================================================

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});
  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<XFile> _selectedFiles =
      []; // Folosim XFile direct pentru a stoca și numele/extensia
  final ScrollController _scrollController = ScrollController();
  bool _isUploading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final picker = ImagePicker();
    // pickMultipleMedia permite selecția și de poze, și de video!
    final pickedFiles = await picker.pickMultipleMedia();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedFiles = pickedFiles;
      });
    }
  }

  Future<void> _submitFiles() async {
    final uri = Uri.parse(const String.fromEnvironment('UPLOAD_URL',
        defaultValue: 'https://YOUR_API_GATEWAY_URL/upload'));

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isUploading = true);

    try {
      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        final fileBytes = await file.readAsBytes();
        final fileName = file.name;

        // Detectăm automat MIME tipul (ex: video/mp4, image/jpeg, etc.)
        final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

        // 1. Cerem link-ul temporar de la AWS
        final apiResponse = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "fileName": fileName,
            "contentType": mimeType,
          }),
        );

        if (apiResponse.statusCode != 200) {
          throw Exception('Eroare link temporar AWS.');
        }

        final responseData = jsonDecode(apiResponse.body);
        final String uploadUrl = responseData['uploadUrl'];

        // 2. Uploadăm efectiv fișierul (poză sau video) direct în S3
        final s3Response = await http.put(
          Uri.parse(uploadUrl),
          headers: {
            "Content-Type": mimeType,
          },
          body: fileBytes,
        );

        if (s3Response.statusCode != 200 && s3Response.statusCode != 204) {
          throw Exception('Eroare upload S3.');
        }
      }

      setState(() => _isUploading = false);
      messenger.showSnackBar(const SnackBar(
          content: Text('Succes! Fișierele au fost încărcate.')));

      setState(() {
        _selectedFiles.clear();
      });
    } catch (e) {
      setState(() => _isUploading = false);
      messenger.showSnackBar(SnackBar(content: Text('Eroare: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasFiles = _selectedFiles.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
          title: Text('Redacția Foto & Video',
              style: GoogleFonts.cinzel(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFFEFECE5)),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('Ați surprins un moment special?',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Încărcați fotografiile și videoclipurile aici.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(color: Colors.grey[700])),
              const SizedBox(height: 30),
              OutlinedButton.icon(
                onPressed: _pickFiles, // Folosim noua funcție
                icon: const Icon(Icons.folder_open, color: Colors.black),
                label: const Text('SELECTEAZĂ',
                    style: TextStyle(color: Colors.black)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15)),
              ),
              const SizedBox(height: 20),
              if (hasFiles) ...[
                SizedBox(
                  height: 120,
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedFiles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        final mime = lookupMimeType(file.name) ?? '';
                        final isVideo = mime.startsWith('video/');

                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          // Aici decidem ce arătăm: poză sau iconiță de video
                          child: isVideo
                              ? const Center(
                                  child: Icon(Icons.videocam,
                                      size: 40, color: Colors.black54),
                                )
                              : kIsWeb
                                  ? Image.network(file.path, fit: BoxFit.cover)
                                  : Image.file(File(file.path),
                                      fit: BoxFit.cover),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isUploading)
                  const CircularProgressIndicator(color: Colors.black)
                else
                  ElevatedButton.icon(
                    onPressed: _submitFiles,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text('TRIMITE'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: const BeveledRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15)),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  String _getExtension(String url) {
    final path = Uri.parse(url).path.toLowerCase();
    if (path.endsWith('.mp4')) return '.mp4';
    if (path.endsWith('.mov')) return '.mov';
    if (path.endsWith('.png')) return '.png';
    if (path.endsWith('.jpeg')) return '.jpeg';
    return '.jpg';
  }

  bool _isVideo(String url) {
    final ext = _getExtension(url);
    return ext == '.mp4' || ext == '.mov';
  }

  Future<List<String>> fetchMediaUrls() async {
    const apiUrl = String.fromEnvironment('GALLERY_URL',
        defaultValue: 'https://YOUR_API_GATEWAY_ENDPOINT/gallery');

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data['images'] is List)
        return List<String>.from(data['images']);
      if (data is List) return data.cast<String>();
      if (data is Map && data['photos'] is List) {
        return (data['photos'] as List)
            .where((photo) => photo is Map && photo['url'] != null)
            .map<String>((photo) => photo['url'] as String)
            .toList();
      }
      throw Exception('Format necunoscut de răspuns');
    } else {
      throw Exception('Nu s-au putut încărca fișierele');
    }
  }

  // Logica de download regândită pentru a preveni blocarea aplicației (OOM - Out of Memory)
  Future<void> _downloadMedia(BuildContext context, String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Se pregătește descărcarea...'),
          duration: Duration(seconds: 2)),
    );

    final isVideo = _isVideo(url);

    // PENTRU WEB SAU VIDEO:
    // Evităm descărcarea în RAM a fișierelor mari. Delegăm sarcina către browser/sistem.
    if (kIsWeb || isVideo) {
      try {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Eroare la deschidere.')));
      }
      return;
    }

    // PENTRU IMAGINI PE TELEFON (Mobile):
    // Pozele sunt mici, deci e sigur să le descărcăm și să le dăm share.
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ext = _getExtension(url);

        final tempDir = await getTemporaryDirectory();
        final file =
            File('${tempDir.path}/nunta_andreea_adelin_$timestamp$ext');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Amintire Nuntă');
      } else {
        throw 'Eroare HTTP: ${response.statusCode}';
      }
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Eroare: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Galeria',
              style: GoogleFonts.cinzel(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFFEFECE5)),
      backgroundColor: const Color(0xFFEFECE5),
      body: FutureBuilder<List<String>>(
        future: fetchMediaUrls(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Eroare: ${snapshot.error}',
                    style: GoogleFonts.lora()));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('Niciun fișier încărcat momentan.',
                    style: GoogleFonts.lora()));
          }

          final mediaUrls = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85),
            itemCount: mediaUrls.length,
            itemBuilder: (context, index) {
              final url = mediaUrls[index];
              final isVideo = _isVideo(url);

              return GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(10),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                              maxWidth: 800),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // AICI e player-ul embedded pentru popup
                              Expanded(
                                  child: isVideo
                                      ? DialogVideoPlayer(url: url)
                                      : Image.network(url,
                                          fit: BoxFit.contain)),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                  onPressed: () => _downloadMedia(context, url),
                                  icon: const Icon(Icons.download,
                                      size: 16, color: Colors.white),
                                  label: const Text("DESCARCĂ / DESCHIDE"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: const BeveledRectangleBorder(
                                          borderRadius: BorderRadius.zero)))
                            ],
                          ),
                        ),
                        Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton(
                                icon: const CircleAvatar(
                                    backgroundColor: Colors.black,
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 20)),
                                onPressed: () => Navigator.pop(context)))
                      ],
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, offset: Offset(3, 3))
                      ]),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // AICI e preview-ul pentru grid
                      Expanded(
                          child: Container(
                              color: Colors.black,
                              child: isVideo
                                  ? GridVideoPreview(url: url)
                                  : Image.network(url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          const Icon(Icons.broken_image,
                                              color: Colors.white)))),
                      const SizedBox(height: 8),
                      Text(isVideo ? 'Video ${index + 1}' : 'Foto ${index + 1}',
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

// ============================================================================
// WIDGET-URI NOI PENTRU REDARE VIDEO (Preview și Full)
// ============================================================================

class GridVideoPreview extends StatefulWidget {
  final String url;
  const GridVideoPreview({super.key, required this.url});

  @override
  State<GridVideoPreview> createState() => _GridVideoPreviewState();
}

class _GridVideoPreviewState extends State<GridVideoPreview> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    // AICI E SECRETUL: ClipRect taie excesul vizual care iese din cadru
    return ClipRect(
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
          const Icon(Icons.play_circle_outline, color: Colors.white, size: 40),
        ],
      ),
    );
  }
}

class DialogVideoPlayer extends StatefulWidget {
  final String url;
  const DialogVideoPlayer({super.key, required this.url});

  @override
  State<DialogVideoPlayer> createState() => _DialogVideoPlayerState();
}

class _DialogVideoPlayerState extends State<DialogVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
          _controller.play(); // Auto-play la deschiderea popup-ului
          _controller.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.black));
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            Container(
              decoration: const BoxDecoration(
                  color: Colors.black45, shape: BoxShape.circle),
              child:
                  const Icon(Icons.play_arrow, color: Colors.white, size: 60),
            ),
        ],
      ),
    );
  }
}
