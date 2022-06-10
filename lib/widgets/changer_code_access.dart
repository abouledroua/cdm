import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm/classes/data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangeAccessCode extends StatefulWidget {
  const ChangeAccessCode({Key? key}) : super(key: key);

  @override
  State<ChangeAccessCode> createState() => _ChangeAccessCodeState();
}

class _ChangeAccessCodeState extends State<ChangeAccessCode> {
  FocusNode focusNode = FocusNode();
  bool valAncCode = false, valNouvCode = false, valider = false;
  TextEditingController txtAncCode = TextEditingController(text: "");
  TextEditingController txtNouvCode = TextEditingController(text: "");

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: Data.maxWidth),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25))),
                padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 10,
                    bottom: 10 + MediaQuery.of(context).viewInsets.bottom),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(AppLocalizations.of(context)!.txtModifCodeAccess,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.laila(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip),
                  const SizedBox(height: 16),
                  TextField(
                      autofocus: true,
                      focusNode: focusNode,
                      enabled: !valider,
                      controller: txtAncCode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      decoration: InputDecoration(
                          errorText: valAncCode
                              ? AppLocalizations.of(context)!
                                  .txtChampsObligatoire
                              : null,
                          prefixIcon: const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.key, color: Colors.grey)),
                          contentPadding: const EdgeInsets.only(bottom: 3),
                          labelText: AppLocalizations.of(context)!.txtOldCode,
                          labelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          hintText: AppLocalizations.of(context)!.txtOldCode,
                          hintStyle:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          floatingLabelBehavior: FloatingLabelBehavior.always)),
                  const SizedBox(height: 16),
                  TextField(
                      enabled: !valider,
                      controller: txtNouvCode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                          errorText: valNouvCode
                              ? AppLocalizations.of(context)!
                                  .txtChampsObligatoire
                              : null,
                          prefixIcon: const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.key, color: Colors.black)),
                          contentPadding: const EdgeInsets.only(bottom: 3),
                          labelText: AppLocalizations.of(context)!.txNewCode,
                          labelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          hintText: AppLocalizations.of(context)!.txNewCode,
                          hintStyle:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          floatingLabelBehavior: FloatingLabelBehavior.always)),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Spacer(flex: 2),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: TextButton.icon(
                            onPressed: fnValider,
                            icon: const Icon(Icons.verified_rounded,
                                color: Colors.white),
                            label: Text(
                                AppLocalizations.of(context)!.txtModifier,
                                style: TextStyle(color: Colors.white)))),
                    const Spacer(flex: 1),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.cancel_outlined,
                                color: Colors.white),
                            label: Text(
                                AppLocalizations.of(context)!.txtAnnuler,
                                style: TextStyle(color: Colors.white)))),
                    const Spacer(flex: 2)
                  ]),
                  const SizedBox(height: 8)
                ]))));
  }

  fnValider() async {
    setState(() {
      valider = true;
      valAncCode = txtAncCode.text.isEmpty;
      valNouvCode = txtNouvCode.text.isEmpty;
    });
    if (valAncCode || valNouvCode) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: AppLocalizations.of(context)!.txtErreur,
              desc: AppLocalizations.of(context)!.txtErrChampsObligatoire)
          .show();
      setState(() {
        valider = false;
      });
    } else {
      print("valider");
      updateCode();
    }
  }

  updateCode() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/UPDATE_CODE.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      "ID_ADMIN": Data.isAdmin.toString(),
      "CODE_OLD": txtAncCode.text.toUpperCase(),
      "CODE_NEW": txtNouvCode.text.toUpperCase()
    }).then((response) async {
      if (response.statusCode == 200) {
        int responsebody = int.parse(response.body.replaceAll('"', ''));
        print("Response=$responsebody");
        if (responsebody == 1) {
          Data.showSnack(
              msg: AppLocalizations.of(context)!.txtSucessUpdate,
              color: Colors.green);
          Navigator.of(context).pop();
        } else if (responsebody == 2) {
          setState(() {
            valider = false;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: AppLocalizations.of(context)!.txtErreur,
                  desc: AppLocalizations.of(context)!.txtErrCodeAncien)
              .show();
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
}
