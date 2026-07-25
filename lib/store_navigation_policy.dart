/// Main-frame navigation policy for the website-backed app.
///
/// Normal storefront browsing stays on BeautyOnTApp. External web pages,
/// including app-download and promotional destinations, are inert inside the
/// app. An external redirect is allowed only after the customer has entered a
/// first-party checkout, account, or OAuth flow so payments and sign-in keep
/// working.
abstract final class StoreNavigationPolicy {
  static bool isFirstParty(String? url) {
    final Uri? uri = Uri.tryParse(url ?? '');
    if (uri == null || uri.scheme != 'https') return false;
    final String host = uri.host.toLowerCase();
    return host == 'beautyontapp.com' || host.endsWith('.beautyontapp.com');
  }

  static bool isProtectedFirstPartyFlow(String? url) {
    final Uri? uri = Uri.tryParse(url ?? '');
    if (uri == null || !isFirstParty(url)) return false;

    final String host = uri.host.toLowerCase();
    if (host == 'account.beautyontapp.com' ||
        host.endsWith('.account.beautyontapp.com')) {
      return true;
    }

    final String path = uri.path.toLowerCase();
    return path == '/checkout' ||
        path.startsWith('/checkout/') ||
        path == '/checkouts' ||
        path.startsWith('/checkouts/') ||
        path == '/account' ||
        path.startsWith('/account/') ||
        path == '/oauth' ||
        path.startsWith('/oauth/');
  }

  static bool isHostedCustomerAccount(String? url) {
    final Uri? uri = Uri.tryParse(url ?? '');
    if (uri == null || uri.scheme != 'https') return false;
    final String host = uri.host.toLowerCase();
    return host == 'account.beautyontapp.com' ||
        host.endsWith('.account.beautyontapp.com');
  }

  static bool isHostedCustomerLogin(String? url) {
    final Uri? uri = Uri.tryParse(url ?? '');
    if (uri == null || !isHostedCustomerAccount(url)) return false;
    return uri.path.toLowerCase().startsWith('/authentication/login');
  }

  static bool isHostedSocialSignInDestination(String? url) {
    final Uri? uri = Uri.tryParse(url ?? '');
    if (uri == null || !isHostedCustomerAccount(url)) return false;
    return uri.path.toLowerCase().startsWith('/authentication/social/');
  }

  static bool isGoogleSignInDestination(String? url) {
    final Uri? uri = Uri.tryParse(url ?? '');
    if (uri == null || uri.scheme != 'https') return false;
    final String host = uri.host.toLowerCase();
    return host == 'accounts.google.com' ||
        host.endsWith('.accounts.google.com') ||
        (isHostedSocialSignInDestination(url) &&
            uri.path.toLowerCase().startsWith('/authentication/social/google'));
  }

  static bool isAppDistributionDestination(String? url) {
    final Uri? uri = Uri.tryParse(url ?? '');
    if (uri == null) return false;

    final String scheme = uri.scheme.toLowerCase();
    if (scheme == 'market' || scheme == 'itms-apps') return true;
    if (scheme != 'https') return false;

    final String host = uri.host.toLowerCase();
    return host == 'apps.apple.com' ||
        host.endsWith('.apps.apple.com') ||
        host == 'itunes.apple.com' ||
        host.endsWith('.itunes.apple.com') ||
        host == 'play.google.com' ||
        host.endsWith('.play.google.com');
  }

  static bool shouldAllowMainFrame(
    String? destinationUrl, {
    required bool protectedFlowActive,
  }) {
    final Uri? destination = Uri.tryParse(destinationUrl ?? '');
    if (destination == null) return false;

    if (isAppDistributionDestination(destinationUrl)) return false;

    if (destination.scheme == 'https') {
      return isFirstParty(destinationUrl) || protectedFlowActive;
    }

    return destination.scheme == 'about' ||
        destination.scheme == 'data' ||
        destination.scheme == 'blob';
  }
}
