import 'package:cdm/acceuil/acceuil.dart';
import 'package:cdm/classes/data.dart';
import 'package:cdm/provider/local_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late SharedPreferences prefs;

  @override
  initState() {
    WidgetsFlutterBinding.ensureInitialized();
    Data.getDeviceUniqueId();
    getSharedPrefs();
    super.initState();
  }

  void onClose() {
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            maintainState: true,
            opaque: true,
            pageBuilder: (context, _, __) => const PageAcceuil(),
            transitionDuration: const Duration(seconds: 2),
            transitionsBuilder: (context, anim1, anim2, child) {
              return FadeTransition(opacity: anim1, child: child);
            }));
  }

  getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    String? serverIP = prefs.getString('ServerIp');
    String? langue = prefs.getString('Langue');
    langue ??= 'fr';
    final provider = Provider.of<LocalProvider>(context, listen: false);
    provider.setLocale(Locale(langue));
    var local = prefs.getString('LocalIP');
    var intenet = prefs.getString('InternetIP');
    var mode = prefs.getInt('NetworkMode');
    mode ??= 2;
    await Data.setNetworkMode(mode);
    local ??= "192.168.1.152";
    intenet ??= "atlasschool.dz";
    serverIP ??= mode == 1 ? local : intenet;
    if (serverIP != "") Data.setServerIP(serverIP);
    if (local != "") Data.setLocalIP(local);
    if (intenet != "") Data.setInternetIP(intenet);
    print("serverIP=$serverIP");
    Timer(const Duration(seconds: 3), onClose);
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                          child:
                              Image.asset("images/CDM.png", fit: BoxFit.cover)),
                      const SizedBox(height: 20),
                      Text("حرفيــون .. جميعهم بين يديك",
                          style: GoogleFonts.actor())
                    ]))));
  }
}
