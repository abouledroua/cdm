import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm/classes/data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FicheSpecialite extends StatefulWidget {
  final int idSpecialite;
  const FicheSpecialite({Key? key, required this.idSpecialite})
      : super(key: key);

  @override
  State<FicheSpecialite> createState() => _FicheSpecialiteState();
}

class _FicheSpecialiteState extends State<FicheSpecialite> {
  late int idSpecialite;
  bool loading = false,
      valDes = false,
      valDesAr = false,
      isSwitched = true,
      valider = false;
  TextEditingController txtDes = TextEditingController(text: "");
  TextEditingController txtDesAr = TextEditingController(text: "");
  FocusNode focusNodeFr = FocusNode(), focusNodeAr = FocusNode();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    idSpecialite = widget.idSpecialite;
    loading = false;
    valider = false;
    if (idSpecialite == 0) {
      setState(() {
        loading = false;
      });
    } else {
      getSpecialiteInfo();
    }
    super.initState();
  }

  getSpecialiteInfo() async {
    setState(() {
      loading = true;
    });
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_INFO_SPECIALITES.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_SPECIALITE": idSpecialite.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            for (var m in responsebody) {
              txtDes.text = m['DESIGNATION'];
              txtDesAr.text = m['DESIGNATION_AR'];
              int petat = int.parse(m['ETAT']);
              isSwitched = (petat == 1);
            }
            setState(() {
              loading = false;
            });
          } else {
            setState(() {
              loading = false;
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
          setState(() {
            loading = false;
          });
          print("erreur : $error");
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
  void dispose() {
    focusNodeFr.dispose();
    focusNodeAr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    double minSize = min(Data.heightScreen, Data.widthScreen) / 2;
    return GestureDetector(
        child: SafeArea(
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage("images/artisan_opacity.png"))),
                    child: Center(
                        child: Container(
                            constraints:
                                BoxConstraints(maxWidth: Data.maxWidth),
                            padding: const EdgeInsets.all(16),
                            child: Column(children: [
                              Row(children: [
                                InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Ink(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(Icons.arrow_back))),
                                const Spacer(),
                                Text(
                                    AppLocalizations.of(context)!
                                        .txtTitreFicheSpecialite,
                                    style: GoogleFonts.abel(
                                        color: Colors.brown,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26)),
                                const Spacer()
                              ]),
                              const SizedBox(height: 10),
                              loading
                                  ? const Center(
                                      child:
                                          CircularProgressIndicator.adaptive())
                                  : Expanded(child: bodyContent(minSize))
                            ])))))));
  }

  Widget bodyContent(double minSize) => valider
      ? Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(AppLocalizations.of(context)!.txtValidationEnCours),
          const SizedBox(width: 10),
          const CircularProgressIndicator.adaptive()
        ]))
      : ListView(primary: false, shrinkWrap: true, children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              child: TextField(
                  autofocus: true,
                  focusNode: focusNodeFr,
                  enabled: !valider,
                  controller: txtDes,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                      errorText: valDes
                          ? AppLocalizations.of(context)!.txtChampsObligatoire
                          : null,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.supervised_user_circle_outlined,
                              color: Colors.black)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "Désignation de la Spécialité (Fr - Eng)",
                      labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      hintText: "Désignation de la Spécialité (Fr - Eng)",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextField(
                  focusNode: focusNodeAr,
                  enabled: !valider,
                  controller: txtDesAr,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                      errorText: valDesAr
                          ? AppLocalizations.of(context)!.txtChampsObligatoire
                          : null,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.supervised_user_circle_outlined,
                              color: Colors.black)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "إسم المهنـة بالعربية",
                      labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      hintText: "إسم المهنـة بالعربية",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Switch(
                value: isSwitched,
                onChanged: (value) {
                  if (!valider) {
                    setState(() {
                      isSwitched = !isSwitched;
                    });
                  }
                }),
            const SizedBox(width: 5),
            Text(isSwitched ? "Actif" : "Inactif",
                style: const TextStyle(color: Colors.black))
          ]),
          const SizedBox(height: 16),
          Row(children: [
            const Spacer(flex: 2),
            Container(
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: TextButton.icon(
                    onPressed: fnValider,
                    icon:
                        const Icon(Icons.verified_rounded, color: Colors.white),
                    label: Text(AppLocalizations.of(context)!.txtValider,
                        style: TextStyle(color: Colors.white)))),
            const Spacer(flex: 1),
            Container(
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: TextButton.icon(
                    onPressed: () {
                      AwesomeDialog(
                              context: context,
                              dialogType: DialogType.QUESTION,
                              showCloseIcon: true,
                              btnOkText: AppLocalizations.of(context)!.txtOui,
                              btnOkOnPress: () {
                                Navigator.pop(context);
                              },
                              btnCancelText:
                                  AppLocalizations.of(context)!.txtNon,
                              btnCancelOnPress: () {},
                              title: '',
                              desc: AppLocalizations.of(context)!
                                  .txtQuestionAnnuler)
                          .show();
                    },
                    icon:
                        const Icon(Icons.cancel_outlined, color: Colors.white),
                    label: Text(AppLocalizations.of(context)!.txtAnnuler,
                        style: TextStyle(color: Colors.white)))),
            const Spacer(flex: 2)
          ])
        ]);

  fnValider() async {
    bool continuer = true;
    setState(() {
      valider = true;
      valDes = txtDes.text.isEmpty;
      valDesAr = txtDesAr.text.isEmpty;
    });
    if (valDes && valDesAr) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: AppLocalizations.of(context)!.txtErreur,
              desc: AppLocalizations.of(context)!.txtErrDesSpecialite)
          .show();
      continuer = false;
    }
    if (continuer) {
      print("valider");
      existSpecialite();
    } else {
      setState(() {
        valider = false;
      });
    }
  }

  existSpecialite() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/EXIST_SPECIALITE.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "DESIGNATION": txtDes.text,
          "ID_SPECIALITE": idSpecialite.toString(),
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            int result = 0;
            for (var m in responsebody) {
              result = int.parse(m['ID_SPECIALITE']);
            }
            if (result == 0) {
              if (idSpecialite == 0) {
                insertSpecialite();
              } else {
                updateSpecialite();
              }
            } else {
              setState(() {
                valider = false;
              });
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: AppLocalizations.of(context)!.txtErreur,
                  desc: AppLocalizations.of(context)!.txtErrExisteDeja);
            }
          } else {
            setState(() {
              valider = false;
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
            valider = false;
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

  updateSpecialite() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/UPDATE_SPECIALITE.php";
    print(url);
    int petat = isSwitched ? 1 : 2;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      "ID_SPECIALITE": idSpecialite.toString(),
      "DESIGNATION": txtDes.text.toUpperCase(),
      "DESIGNATION_AR": txtDesAr.text.toUpperCase(),
      "ETAT": petat.toString()
    }).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("Response=$responsebody");
        if (responsebody != "0") {
          Data.showSnack(
              msg: AppLocalizations.of(context)!.txtSucessUpdate,
              color: Colors.green);
          Navigator.of(context).pop();
        } else {
          setState(() {
            valider = false;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: AppLocalizations.of(context)!.txtErreur,
                  desc: AppLocalizations.of(context)!.txtProblemeUpdate)
              .show();
        }
      } else {
        setState(() {
          valider = false;
        });
        AwesomeDialog(
                context: context,
                dialogType: DialogType.ERROR,
                showCloseIcon: true,
                title: AppLocalizations.of(context)!.txtErreur,
                desc: AppLocalizations.of(context)!.txtProblemeServeur)
            .show();
      }
    }).catchError((error) {
      print("erreur : $error");
      setState(() {
        valider = false;
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

  insertSpecialite() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/INSERT_SPECIALITE.php";
    print(url);
    int petat = isSwitched ? 1 : 2;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      "DESIGNATION": txtDes.text.toUpperCase(),
      "DESIGNATION_AR": txtDesAr.text.toUpperCase(),
      "ETAT": petat.toString()
    }).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("Response=$responsebody");
        if (responsebody != "0") {
          Data.showSnack(msg: 'Spécialité Ajoutée ...', color: Colors.green);
          Navigator.of(context).pop();
        } else {
          setState(() {
            valider = false;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: AppLocalizations.of(context)!.txtErreur,
                  desc: AppLocalizations.of(context)!.txtProblemeInsert)
              .show();
        }
      } else {
        setState(() {
          valider = false;
        });
        AwesomeDialog(
                context: context,
                dialogType: DialogType.ERROR,
                showCloseIcon: true,
                title: AppLocalizations.of(context)!.txtErreur,
                desc: AppLocalizations.of(context)!.txtProblemeServeur)
            .show();
      }
    }).catchError((error) {
      print("erreur : $error");
      setState(() {
        valider = false;
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
}
