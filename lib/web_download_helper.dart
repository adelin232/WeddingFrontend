// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadWeb(List<int> bytes, String fileName) {
  // 1. Specificăm clar că este o imagine JPEG
  final blob = html.Blob([bytes], 'image/jpeg');

  // 2. Creăm URL-ul local
  final url = html.Url.createObjectUrlFromBlob(blob);

  // 3. Creăm elementul <a>
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName) // Aici setăm numele
    ..style.display = 'none'; // Îl ascundem să nu se vadă pe ecran

  // 4. CRITIC: Adăugăm elementul în pagina HTML (în body)
  // Fără pasul ăsta, unele browsere (Chrome/Safari) ignoră atributul 'download'
  html.document.body!.children.add(anchor);

  // 5. Simulăm click-ul
  anchor.click();

  // 6. Curățenie: ștergem elementul și revocăm URL-ul din memorie
  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
