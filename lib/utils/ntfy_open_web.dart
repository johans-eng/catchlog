import 'package:web/web.dart' as web;

void launchDeepLink(String uri) {
  web.window.location.href = uri;
}
