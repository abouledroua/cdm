import 'package:cdm/acceuil/admin_acceuil.dart';
import 'package:cdm/classes/data.dart';
import 'package:cdm/l10n/l10n.dart';
import 'package:cdm/lists/list_specialites.dart';
import 'package:cdm/provider/local_provider.dart';
import 'package:cdm/acceuil/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LocalProvider(),
        builder: (context, child) {
          final provider = Provider.of<LocalProvider>(context);
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'CDM Clients',
              theme: ThemeData(
                  primarySwatch: Colors.blue,
                  scaffoldBackgroundColor: Colors.white,
                  inputDecorationTheme: const InputDecorationTheme(
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 1))),
                  textTheme: const TextTheme(
                      caption: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors.black))),
              routes: {
                "": (context) =>
                    Data.isAdmin ? const AcceuilAdmin() : const ListSpecialite()
              },
              locale: provider.locale,
              supportedLocales: L10n.all,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              home: const WelcomePage());
        });
  }
}
