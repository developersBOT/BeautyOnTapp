import Flutter
import UIKit
import WebKit
import webview_flutter_wkwebview

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var webViewPolicyChannel: FlutterMethodChannel?

  private static let geolocationGuardScript = """
    (() => {
      const host = location.hostname.toLowerCase();
      const isStorefront =
        host === 'beautyontapp.com' ||
        (host.endsWith('.beautyontapp.com') &&
          host !== 'account.beautyontapp.com' &&
          !host.endsWith('.account.beautyontapp.com'));
      if (!isStorefront || window.__botNativeGeolocationGuard) return;
      window.__botNativeGeolocationGuard = true;

      const geolocation = navigator.geolocation;
      if (!geolocation) return;

      const deniedError = Object.freeze({
        code: 1,
        message: 'Location is unavailable inside the BeautyonTApp app.'
      });
      const deny = (_success, error) => {
        if (typeof error === 'function') {
          setTimeout(() => error(deniedError), 0);
        }
      };
      const denyWatch = (success, error) => {
        deny(success, error);
        return 0;
      };
      const clearWatch = () => {};
      const install = (target, name, value) => {
        if (!target) return;
        try {
          Object.defineProperty(target, name, {
            configurable: false,
            enumerable: true,
            value,
            writable: false
          });
        } catch (_) {
          try {
            target[name] = value;
          } catch (_) {}
        }
      };

      install(geolocation, 'getCurrentPosition', deny);
      install(geolocation, 'watchPosition', denyWatch);
      install(geolocation, 'clearWatch', clearWatch);
      const prototype = Object.getPrototypeOf(geolocation);
      install(prototype, 'getCurrentPosition', deny);
      install(prototype, 'watchPosition', denyWatch);
      install(prototype, 'clearWatch', clearWatch);
    })();
    """

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let pluginRegistry = engineBridge.pluginRegistry
    let channel = FlutterMethodChannel(
      name: "beautyontapp/webview_policy",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "installGeolocationGuard" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let arguments = call.arguments as? [String: Any],
        let identifier = arguments["webViewIdentifier"] as? NSNumber,
        let webView = FWFWebViewFlutterWKWebViewExternalAPI.webView(
          forIdentifier: identifier.int64Value,
          withPluginRegistry: pluginRegistry
        )
      else {
        result(
          FlutterError(
            code: "WEBVIEW_NOT_FOUND",
            message: "Unable to prepare the native storefront WebView.",
            details: nil
          )
        )
        return
      }

      webView.configuration.userContentController.addUserScript(
        WKUserScript(
          source: Self.geolocationGuardScript,
          injectionTime: .atDocumentStart,
          forMainFrameOnly: false
        )
      )
      result(nil)
    }
    webViewPolicyChannel = channel
  }
}
