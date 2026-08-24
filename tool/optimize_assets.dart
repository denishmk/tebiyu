// Development tool. Not shipped with the app.
//
// Normalises category image names and resizes them to sensible dimensions.
// Run once from the project root:
//
//   dart run tool/optimize_assets.dart
//
// Reads from assets/images/category and writes to assets/images/categories,
// leaving the originals untouched so a bad run costs nothing. Verify the
// output, then delete the old folder.
//
// Two problems are being solved. The category images average 2.2MB each for
// artwork that renders at about 64px, which is roughly thirty times more data
// than the screen can use. And the file names carry spaces, mixed case and
// three different extensions, which is how "asset not found" errors reach a
// device instead of being caught at build time.

import 'dart:io';

import 'package:image/image.dart';

/// Longest edge for a main category icon.
const int categorySize = 256;

/// Longest edge for a subcategory photo. Covers a three column tablet grid at
/// 2x density with room to spare.
const int subcategorySize = 480;

/// Folder names that do not match their category name.
const Map<String, String> folderAliases = {
  'baby and kids': 'babies and kids',
  'vehicle': 'vehicles',
};

/// Typos worth fixing while everything is being renamed anyway.
const Map<String, String> nameFixes = {
  'bags and lugggage': 'bags_and_luggage',
  'restauarant and catering equipment': 'restaurant_and_catering_equipment',
  'charges and cables': 'chargers_and_cables',
  'lesiure activities': 'leisure_activities',
  'computer and laptop': 'computers_and_laptops',
  'outwear': 'outerwear',
  'musical instrument': 'musical_instruments',
  'water sport': 'water_sports',
  'sport wear and accessories': 'sportswear_and_accessories',
  'car': 'cars',
  'motorcycle': 'motorcycles',
  'power bank': 'power_banks',
  'perfumes': 'fragrance',
};

String slug(String raw) {
  final withoutExtension = raw.contains('.')
      ? raw.substring(0, raw.lastIndexOf('.'))
      : raw;
  final lower = withoutExtension.toLowerCase().trim();

  if (nameFixes.containsKey(lower)) return nameFixes[lower]!;

  return lower
      .replaceAll(RegExp('[^a-z0-9]+'), '_')
      .replaceAll(RegExp('_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

Future<int> convert(File source, String destinationPath, int maxEdge) async {
  final decoded = decodeImage(await source.readAsBytes());
  if (decoded == null) {
    stdout.writeln('  SKIPPED (could not decode): ${source.path}');
    return 0;
  }

  final longest = decoded.width > decoded.height
      ? decoded.width
      : decoded.height;
  final resized = longest > maxEdge
      ? copyResize(
          decoded,
          width: decoded.width >= decoded.height ? maxEdge : null,
          height: decoded.height > decoded.width ? maxEdge : null,
          interpolation: Interpolation.average,
        )
      : decoded;

  // Transparency has to survive, so anything with an alpha channel stays PNG.
  // Everything else becomes JPEG, which is far smaller for photographs.
  final hasAlpha = resized.numChannels == 4;
  final bytes = hasAlpha
      ? encodePng(resized, level: 8)
      : encodeJpg(resized, quality: 82);
  final path = '$destinationPath.${hasAlpha ? 'png' : 'jpg'}';

  final out = File(path);
  await out.parent.create(recursive: true);
  await out.writeAsBytes(bytes);

  return bytes.length;
}

Future<void> main() async {
  final root = Directory('assets/images/category');
  if (!root.existsSync()) {
    stderr.writeln('Run this from the project root.');
    exit(1);
  }

  var before = 0;
  var after = 0;
  var count = 0;

  stdout.writeln('Main categories');
  final mainDir = Directory('${root.path}/categories');
  for (final entity in mainDir.listSync().whereType<File>()) {
    final name = entity.uri.pathSegments.last;
    before += entity.lengthSync();
    final written = await convert(
      entity,
      'assets/images/categories/main/${slug(name)}',
      categorySize,
    );
    after += written;
    count++;
    stdout.writeln('  ${slug(name)}');
  }

  stdout.writeln('\nSubcategories');
  final subRoot = Directory('${root.path}/sub-categories');
  for (final folder in subRoot.listSync().whereType<Directory>()) {
    final rawFolder = folder.uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .last
        .toLowerCase();
    final resolved = folderAliases[rawFolder] ?? rawFolder;
    final folderSlug = slug(resolved);

    final files = folder.listSync().whereType<File>().toList();
    if (files.isEmpty) {
      stdout.writeln('  $folderSlug — EMPTY, nothing to convert');
      continue;
    }

    stdout.writeln('  $folderSlug (${files.length})');
    for (final entity in files) {
      final name = entity.uri.pathSegments.last;
      before += entity.lengthSync();
      final written = await convert(
        entity,
        'assets/images/categories/sub/$folderSlug/${slug(name)}',
        subcategorySize,
      );
      after += written;
      count++;
    }
  }

  String mb(int bytes) => (bytes / 1024 / 1024).toStringAsFixed(2);
  stdout.writeln(
    '\n$count files. ${mb(before)}MB in, ${mb(after)}MB out.',
  );
}
