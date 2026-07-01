import 'package:web/web.dart' as web;

bool get isIosWeb {
  final ua = web.window.navigator.userAgent.toLowerCase();
  return ua.contains('iphone') ||
      ua.contains('ipad') ||
      ua.contains('ipod') ||
      (ua.contains('macintosh') && web.window.navigator.maxTouchPoints > 1);
}

bool get isAndroidWeb => web.window.navigator.userAgent.toLowerCase().contains('android');

void launchDeepLink(String uri) {
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = uri;
  anchor.style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}
