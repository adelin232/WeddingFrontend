// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadWeb(List<int> bytes, String fileName) {
  // Creăm un "blob" (fișier în memorie)
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Creăm un element <a> invizibil și dăm click pe el
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();

  // Curățăm memoria
  html.Url.revokeObjectUrl(url);
}
