// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:io';

import 'package:cdm/classes/artisan.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Data {
  static String myId = "";
  static int idUser = 0;
  static bool production = true;
  static String serverIP = "";
  static String localIP = "";
  static String internetIP = "";
  static int networkMode = 1, idAdmin = 0;
  static bool upData = false,
      isAdmin = false,
      isLandscape = false,
      isPortrait = false;
  static int timeOut = 0;
  static double minTablet = 450, maxWidth = 800;
  static double widthScreen = double.infinity;
  static late double heightScreen;
  static late double heightmyAppBar;
  static String www = "CDM/WWW";
  static int index = 0;
  static late BuildContext myContext;
  static List<Color> darkColor = [
    Colors.amberAccent,
    Colors.blue,
    Colors.red,
    Colors.amber,
    Colors.blueGrey,
    Colors.blue,
    Colors.green,
    Colors.deepPurple,
    Colors.greenAccent,
    Colors.cyan,
    Colors.blueAccent,
    Colors.brown,
    Colors.cyanAccent,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lime,
    Colors.orange,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.deepPurpleAccent,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.grey,
    Colors.yellow,
    Colors.black12
  ];

  static List<String> listWilaya = [
    "1 - Adrar",
    "2 - Chlef",
    "3 - Laghouat",
    "4 - Oum El Bouaghi",
    "5 - Batna",
    "6 - Béjaïa",
    "7 - Biskra",
    "8 - Béchar",
    "9 - Blida",
    "10 - Bouira",
    "11 - Tamanrasset",
    "12 - Tébessa",
    "13 - Tlemcen",
    "14 - Tiaret",
    "15 - Tizi Ouzou",
    "16 - Alger",
    "17 - Djelfa",
    "18 - Jijel",
    "19 - Sétif",
    "20 - Saïda",
    "21 - Skikda",
    "22 - Sidi Bel Abbès",
    "23 - Annaba",
    "24 - Guelma",
    "25 - Constantine",
    "26 - Médéa",
    "27 - Mostaganem",
    "28 - M'Sila",
    "29 - Mascara",
    "30 - Ouargla",
    "31 - Oran",
    "32 - El Bayadh",
    "33 - Illizi",
    "34 - Bordj Bou Arreridj",
    "35 - Boumerdès",
    "36 - El Tarf",
    "37 - Tindouf",
    "38 - Tissemsilt",
    "39 - El Oued",
    "40 - Khenchela",
    "41 - Souk Ahras",
    "42 - Tipaza",
    "43 - Mila",
    "44 - Aïn Defla",
    "45 - Naâma",
    "46 - Aïn Témouchent",
    "47 - Ghardaïa",
    "48 - Relizane",
    "49 - El M'Ghair",
    "50 - El Meniaa",
    "51 - Ouled Djellal",
    "52 - Bordj Badji Mokhtar",
    "53 - Béni Abbès",
    "54 - Timimoun",
    "55 - Touggourt",
    "56 - Djanet",
    "57 - In Salah",
    "58 - In Guezzam"
  ];

  static String getServerDirectory([port = "80"]) => ((serverIP == "")
      ? ""
      : "https://$serverIP${port != "" && networkMode == 1 ? ":$port" : ""}/$www");

  static String getImage(pImage, pType) =>
      "${getServerDirectory("80")}/IMAGE/$pType/$pImage";

  static setServerIP(ip) async {
    serverIP = ip;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ServerIp', serverIP);
  }

  static setLocalIP(ip) async {
    localIP = ip;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('LocalIP', ip);
  }

  static setInternetIP(ip) async {
    internetIP = ip;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('InternetIP', ip);
  }

  static setNetworkMode(mode) async {
    networkMode = mode;
    (mode == 1) ? timeOut = 5 : timeOut = 7;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('NetworkMode', mode);
    prefs.setInt('TIMEOUT', timeOut);
  }

  static rateWidget({required Artisan item, required double size}) {
    //   if (item.rate == 0) {
    //    return Container();
    // }
    Color color = Colors.red;
    switch (item.rate) {
      case 2:
        color = Colors.orange;
        break;
      case 3:
        color = Colors.amber;
        break;
      case 4:
        color = Colors.greenAccent;
        break;
      case 5:
        color = Colors.green;
        break;
      default:
        color = Colors.red;
        break;
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.rate > 0 ? Icons.star : Icons.star_border_outlined,
              size: size, color: color),
          Icon(item.rate > 1 ? Icons.star : Icons.star_border_outlined,
              size: size, color: color),
          Icon(item.rate > 2 ? Icons.star : Icons.star_border_outlined,
              size: size, color: color),
          Icon(item.rate > 3 ? Icons.star : Icons.star_border_outlined,
              size: size, color: color),
          Icon(item.rate > 4 ? Icons.star : Icons.star_border_outlined,
              size: size, color: color)
        ]);
  }

  static showSnack({required String msg, required Color color}) {
    ScaffoldMessenger.of(myContext)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  static setSizeScreen(context) {
    widthScreen = MediaQuery.of(context).size.width;
    heightScreen = MediaQuery.of(context).size.height;
    isLandscape = widthScreen > heightScreen;
    isPortrait = !isLandscape;
    heightmyAppBar = heightScreen * 0.2;
  }

  static getMyId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      myId = iosDeviceInfo.identifierForVendor!; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      myId = androidDeviceInfo.androidId!; // unique ID on Android
    } else {
      myId = "";
    }
    print("myId=$myId");
  }

  static Future<String> getDeviceUniqueId() async {
    var deviceIdentifier = 'unknown';
    var deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      var webInfo = await deviceInfo.webBrowserInfo;
      deviceIdentifier = webInfo.vendor! +
          webInfo.userAgent! +
          webInfo.hardwareConcurrency.toString();
    } else if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      deviceIdentifier = androidInfo.androidId!;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor!;
    } else if (Platform.isLinux) {
      var linuxInfo = await deviceInfo.linuxInfo;
      deviceIdentifier = linuxInfo.machineId!;
    }
    myId = deviceIdentifier;
    print("myId=$myId");
    return deviceIdentifier;
  }

  static makeExternalRequest(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
