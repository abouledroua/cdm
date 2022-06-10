// ignore_for_file: avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm/classes/data.dart';
import 'package:cdm/classes/specialite.dart';
import 'package:cdm/fiches/fiche_specialite.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfoSpecialite extends StatefulWidget {
  final Specialite spec;
  const InfoSpecialite({Key? key, required this.spec}) : super(key: key);

  @override
  State<InfoSpecialite> createState() => _InfoSpecialiteState();
}

class _InfoSpecialiteState extends State<InfoSpecialite> {
  late int idSpecialite;
  late Specialite item;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    item = widget.spec;
    Data.upData = false;
    super.initState();
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(onTap: () {}, child: child));

  @override
  Widget build(BuildContext context) {
    print("item.etat = ${item.etat}");
    return makeDismissible(
        child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (_, controller) => SafeArea(
                child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25))),
                    padding: const EdgeInsets.all(10),
                    child: ListView(controller: controller, children: [
                      Text(item.designation.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.laila(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip),
                      const SizedBox(height: 10),
                      Text(item.des_ar,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.laila(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip),
                      const Divider(),
                      Wrap(alignment: WrapAlignment.spaceEvenly, children: [
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.green, onPrimary: Colors.white),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                  builder: (context) =>
                                      FicheSpecialite(idSpecialite: item.id));
                              Navigator.of(context)
                                  .push(route)
                                  .then((value) => Navigator.pop(context));
                            },
                            icon: const Icon(Icons.edit),
                            label: Text(
                                AppLocalizations.of(context)!.txtModifier)),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.red, onPrimary: Colors.white),
                            onPressed: () {
                              if (item.nbPersons == 0) {
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.QUESTION,
                                        showCloseIcon: true,
                                        btnOkText: AppLocalizations.of(context)!
                                            .txtOui,
                                        btnOkOnPress: () async {
                                          await deleteSpecialite();
                                        },
                                        btnCancelText:
                                            AppLocalizations.of(context)!
                                                .txtNon,
                                        btnCancelOnPress: () {},
                                        title: '',
                                        desc: AppLocalizations.of(context)!
                                            .txtQuestionDelete)
                                    .show();
                              } else {
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.ERROR,
                                        showCloseIcon: true,
                                        title: AppLocalizations.of(context)!
                                            .txtErreur,
                                        desc: AppLocalizations.of(context)!
                                            .txtErrDelete)
                                    .show();
                              }
                            },
                            icon: const Icon(Icons.delete),
                            label: Text(
                                AppLocalizations.of(context)!.txtSupprimer)),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: item.etat == 2
                                    ? Colors.blue.shade300
                                    : Colors.grey,
                                onPrimary: Colors.white),
                            onPressed: () {
                              updateEtatSpecialite(
                                  idSpecialite: item.id,
                                  pEtat: item.etat == 2 ? 1 : 2);
                            },
                            icon: Icon(item.etat == 2
                                ? Icons.visibility
                                : Icons.visibility_off),
                            label: Text(item.etat == 2
                                ? AppLocalizations.of(context)!
                                    .txtRendreVisibile
                                : AppLocalizations.of(context)!
                                    .txtRendreInVisibile))
                      ])
                    ])))));
  }

  updateEtatSpecialite({required int idSpecialite, required int pEtat}) async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/UPDATE_ETAT_SPECIALITE.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      "ID_SPECIALITE": idSpecialite.toString(),
      "ETAT": pEtat.toString()
    }).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("Response=$responsebody");
        if (responsebody != "0") {
          Data.showSnack(
              msg: AppLocalizations.of(context)!.txtSucessUpdate,
              color: Colors.green);
          Navigator.pop(context);
        } else {
          setState(() {});
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: AppLocalizations.of(context)!.txtErreur,
                  desc: AppLocalizations.of(context)!.txtProblemeUpdate)
              .show();
        }
      } else {
        setState(() {});
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
      setState(() {});
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: AppLocalizations.of(context)!.txtErreur,
              desc: AppLocalizations.of(context)!.txtProblemeServeur)
          .show();
    });
  }

  deleteSpecialite() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/DELETE_SPECIALITE.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_SPECIALITE": item.id.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var result = response.body;
            if (result != "0") {
              Data.showSnack(
                  msg: AppLocalizations.of(context)!.txtSucessDelete,
                  color: Colors.green);
              Data.upData = true;
              Navigator.of(context).pop();
            } else {
              AwesomeDialog(
                      context: context,
                      dialogType: DialogType.ERROR,
                      showCloseIcon: true,
                      title: AppLocalizations.of(context)!.txtErreur,
                      desc: AppLocalizations.of(context)!.txtProblemeDelete)
                  .show();
            }
          } else {
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
