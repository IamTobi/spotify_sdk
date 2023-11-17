import 'dart:convert';

import 'package:http/http.dart' as http;

/// [fetchLatestAppRemoteReleaseAssetDownloadUrl] fetches the latest release of the
/// Spotify Android SDK from GitHub API and returns the name and download url of
/// the spotify-app-remote-release-*.aar asset.
/// Throws an exception if the request fails.
class GitHubApi {
  static const String apiUrl = 'https://api.github.com/repos';
  static const String spotifyAndroidSdkRepo = '/spotify/android-sdk';
  static const String latestRelease = '/releases/latest';
  static const String releaseAsset = '/releases/assets';

  Future<(String, Uri)> fetchLatestAppRemoteReleaseAssetDownloadUrl() async {
    // fetch the github api to get the latest release
    Uri uri = Uri.parse(apiUrl + spotifyAndroidSdkRepo + latestRelease);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assets = data['assets'] as List<dynamic>;

        final assetMap = <int, (String, String)>{};
        for (var asset in assets) {
          final id = asset['id'] as int;
          final name = asset['name'] as String;
          final url = asset['browser_download_url'] as String;
          assetMap[id] = (name, url);
        }

        // find the spotify-app-remote-release-*.aar asset
        final assetId = assetMap.keys.firstWhere(
          (id) =>
              assetMap[id]?.$1.startsWith('spotify-app-remote-release-') ??
              false,
          orElse: () => -1,
        );

        if (assetId == -1) {
          print('Failed to find the Spotify Android SDK asset.');
          throw Exception();
        }

        // return the download url of the spotify-app-remote-release-*.aar asset
        return (assetMap[assetId]!.$1, Uri.parse(assetMap[assetId]!.$2));
      } else {
        print('Failed to fetch data from the API.');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
    throw Exception();
  }
}
