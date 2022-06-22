import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-8245573307366964~1852353081";
    } else {
      throw UnsupportedError('myEror : Unsopported Platform');
    }
  }
}
