import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../lib/widgets/jopies_logo.dart';

/// Renders square PWA icons from [JopiesLogo].
/// Run: flutter run -d windows -t tool/generate_icons.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  for (final size in [192, 512]) {
    final bytes = await _renderSquareIcon(size);
    await File('web/icons/Icon-$size.png').writeAsBytes(bytes);
    await File('web/icons/Icon-maskable-$size.png').writeAsBytes(bytes);
    await File('assets/images/logo.png').writeAsBytes(bytes);
    if (size == 192) {
      await File('web/favicon.png').writeAsBytes(bytes);
    }
    stdout.writeln('Wrote ${size}x$size icons');
  }

  exit(0);
}

Future<List<int>> _renderSquareIcon(int size) async {
  final key = GlobalKey();
  final logoSize = size * 0.62;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF050508),
        body: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: size.toDouble(),
              height: size.toDouble(),
              child: ColoredBox(
                color: const Color(0xFF050508),
                child: Center(child: JopiesLogo(size: logoSize)),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await Future<void>.delayed(const Duration(milliseconds: 200));
  await WidgetsBinding.instance.endOfFrame;

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}
