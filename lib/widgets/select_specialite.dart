// ignore_for_file: avoid_print

import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm/classes/data.dart';
import 'package:cdm/classes/specialite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../provider/local_provider.dart';

class SelectSpecialite extends StatefulWidget {
  const SelectSpecialite({Key? key}) : super(key: key);

  @override
  State<SelectSpecialite> createState() => _SelectSpecialiteState();
}

class _SelectSpecialiteState extends State<SelectSpecialite> {
  List<Specialite> specs = [];
  bool loading = false, error = false;
  late final countryCode, provider;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    provider = Provider.of<LocalProvider>(context, listen: false);
    countryCode = provider.locale?.languageCode;
    getListSpecialite();
    super.initState();
  }

  getListSpecialite() async {
    setState(() {
      loading = true;
      error = false;
    });
    specs.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_SPECIALITIES.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            Specialite e;
            for (var m in responsebody) {
              e = Specialite(
                  des_ar: m['DESIGNATION_AR'],
                  designation: m['DESIGNATION'],
                  etat: int.parse(m['ETAT']),
                  id: int.parse(m['ID_SPECIALITE']),
                  nbPersons: int.parse(m['NB']));
              if (e.etat == 1) {
                specs.add(e);
              }
            }
            setState(() {
              loading = false;
            });
          } else {
            setState(() {
              specs.clear();
              loading = false;
              error = true;
            });
            AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: AppLocalizations.of(context)!.txtErreur,
                    desc: AppLocalizations.of(context)!.txtProblemeServeur)
                .show();
          }
        })
        .catchError((error) {
          print("erreur : $error");
          setState(() {
            specs.clear();
            loading = false;
            error = true;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: AppLocalizations.of(context)!.txtErreur,
                  desc: AppLocalizations.of(context)!.txtProblemeServeur)
              .show();
        });
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: Data.maxWidth),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25))),
                margin: EdgeInsets.only(
                    left: min(Data.widthScreen, Data.heightScreen) / 15,
                    right: min(Data.widthScreen, Data.heightScreen) / 15,
                    top: min(Data.widthScreen, Data.heightScreen) / 15,
                    bottom: min(Data.widthScreen, Data.heightScreen) / 15),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.orange.shade300,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!
                                .txtchooseSpecialite)
                          ])),
                  Visibility(
                      visible: loading,
                      child: Center(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(AppLocalizations.of(context)!
                                        .txtConnexionEnCours),
                                    const SizedBox(width: 10),
                                    const CircularProgressIndicator.adaptive()
                                  ]))),
                      replacement: Visibility(
                          visible: specs.isEmpty,
                          child: Center(
                              child: Text(
                                  error
                                      ? AppLocalizations.of(context)!
                                          .txtProblemeServeur
                                      : AppLocalizations.of(context)!
                                          .txtListeVide,
                                  style: TextStyle(
                                      color: error ? Colors.red : Colors.black,
                                      fontSize: error ? 26 : 22,
                                      fontWeight: error
                                          ? FontWeight.bold
                                          : FontWeight.normal))),
                          replacement: Expanded(
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Wrap(
                                      children: specs
                                          .map((item) {
                                            return InkWell(
                                                onTap: () {
                                                  print(
                                                      "selected specialite $item");
                                                  Navigator.of(context)
                                                      .pop(item);
                                                },
                                                child: Ink(
                                                    padding: EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                        bottom: 10 +
                                                            MediaQuery.of(
                                                                    context)
                                                                .viewInsets
                                                                .bottom),
                                                    child: ListTile(
                                                        title: Text(countryCode ==
                                                                'ar'
                                                            ? item.des_ar
                                                            : item
                                                                .designation))));
                                          })
                                          .toList()
                                          .cast<Widget>())))))
                ]))));
  }
}
