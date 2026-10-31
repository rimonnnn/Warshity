import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  final String latestVersion;
  final String releaseNotes;
  final String apkUrl;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.releaseNotes,
    required this.apkUrl,
  });
}

class AppUpdateService {
  // Assuming the repository is still rimonnnn/Warshity.
  // Change these values if the repository name has changed.
  static const String _owner = 'rimonnnn';
  static const String _repository = 'masiter';

  static const Duration _timeout = Duration(seconds: 10);

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final uri = Uri.https(
        'api.github.com',
        '/repos/$_owner/$_repository/releases/latest',
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'Masiter-App',
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        return null;
      }

      final Object? decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final tagName = decoded['tag_name'];

      if (tagName is! String || tagName.trim().isEmpty) {
        return null;
      }

      final assets = decoded['assets'];

      if (assets is! List) {
        return null;
      }

      // Find the APK attached to the latest published release.
      final apkAssets = assets.whereType<Map<String, dynamic>>().where((asset) {
        final name = asset['name'];

        return name is String && name.toLowerCase().endsWith('.apk');
      }).toList();

      if (apkAssets.isEmpty) {
        return null;
      }

      final apkUrl = apkAssets.first['browser_download_url'];

      if (apkUrl is! String || apkUrl.isEmpty) {
        return null;
      }

      final downloadUri = Uri.tryParse(apkUrl);

      // Only allow APK downloads hosted on GitHub.
      if (downloadUri == null ||
          downloadUri.scheme != 'https' ||
          downloadUri.host != 'github.com') {
        return null;
      }

      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = packageInfo.version;

      if (!_isNewerVersion(tagName, currentVersion)) {
        return null;
      }

      final releaseNotes = decoded['body'];

      return AppUpdateInfo(
        latestVersion: tagName,
        releaseNotes: releaseNotes is String ? releaseNotes : '',
        apkUrl: downloadUri.toString(),
      );
    } catch (_) {
      // An update-check failure must not prevent the app from opening.
      return null;
    }
  }

  bool _isNewerVersion(String latest, String current) {
    final latestParts = _parseVersion(latest);
    final currentParts = _parseVersion(current);

    if (latestParts == null || currentParts == null) {
      return false;
    }

    final length = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;

    for (var i = 0; i < length; i++) {
      final latestPart = i < latestParts.length ? latestParts[i] : 0;

      final currentPart = i < currentParts.length ? currentParts[i] : 0;

      if (latestPart != currentPart) {
        return latestPart > currentPart;
      }
    }

    return false;
  }

  List<int>? _parseVersion(String version) {
    final normalized = version
        .trim()
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('+')
        .first
        .split('-')
        .first;

    final parts = normalized.split('.');

    if (parts.isEmpty) {
      return null;
    }

    final result = <int>[];

    for (final part in parts) {
      final number = int.tryParse(part);

      if (number == null) {
        return null;
      }

      result.add(number);
    }

    return result;
  }
}
