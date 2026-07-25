import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beautyontapp/store_webview.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('Android store root carries the app attribution parameters', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(
      storeRootUri().toString(),
      'https://beautyontapp.com?utm_source=beautyontapp_app&'
      'utm_medium=app&utm_campaign=app_android',
    );
  });

  test('iOS store root carries the app attribution parameters', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    expect(
      storeRootUri().toString(),
      'https://beautyontapp.com?utm_source=beautyontapp_app&'
      'utm_medium=app&utm_campaign=app_ios',
    );
  });

  test('Android Google OAuth browser user agent remains unchanged', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(
      kBrowserUserAgent,
      'Mozilla/5.0 (Linux; Android 15) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36',
    );
  });

  test('iOS Google OAuth browser user agent remains unchanged', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    expect(
      kBrowserUserAgent,
      'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 '
      'Mobile/15E148 Safari/604.1',
    );
  });
}
