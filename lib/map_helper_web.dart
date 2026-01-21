// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;

void registerWebMap(String viewId, String url) {
  ui.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewId) => html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..className = 'map-iframe',
  );
}
