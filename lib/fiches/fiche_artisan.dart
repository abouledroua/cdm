import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm/classes/data.dart';
import 'package:cdm/classes/specialite.dart';
import 'package:cdm/provider/local_provider.dart';
import 'package:cdm/widgets/select_all_wilaya.dart';
import 'package:cdm/widgets/select_specialite.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class FicheArtisan extends StatefulWidget {
  final int idArtisan;
  const FicheArtisan({Key? key, required this.idArtisan}) : super(key: key);

  @override
  State<FicheArtisan> createState() => _FicheArtisanState();
}

class _FicheArtisanState extends State<FicheArtisan> {
  late int idArtisan, indexWilaya;
  Specialite? mySpec;
  bool loading = false,
      valNom = false,
      valTel = false,
      valWilaya = false,
      valSpecialite = false,
      valider = false,
      valAdresse = false,
      isSwitched = true,
      selectPhoto = false;
  TextEditingController txtNom = TextEditingController(text: "");
  TextEditingController txtTel = TextEditingController(text: "");
  TextEditingController txtAdresse = TextEditingController(text: "");
  TextEditingController txtEmail = TextEditingController(text: "");
  TextEditingController txtFacebook = TextEditingController(text: "");
  TextEditingController txtWilaya = TextEditingController(text: "");
  TextEditingController txtSpecialite = TextEditingController(text: "");
  late final countryCode, provider;

  String myPhoto = "";
  final picker = ImagePicker();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    idArtisan = widget.idArtisan;
    provider = Provider.of<LocalProvider>(context, listen: false);
    countryCode = provider.locale?.languageCode;
    loading = false;
    valider = false;
    indexWilaya = 0;
    txtWilaya.text = "";
    Data.upData = false;
    mySpec = null;
    myPhoto = "";
    selectPhoto = false;
    if (idArtisan == 0) {
      setState(() {
        loading = false;
      });
    } else {
      getArtisanInfo();
    }
    super.initState();
  }

  getArtisanInfo() async {
    setState(() {
      loading = true;
    });
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_INFO_ARTISAN.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_ARTISAN": idArtisan.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            for (var m in responsebody) {
              txtNom.text = m['NOM'];
              txtAdresse.text = m['ADRESSE'];
              txtEmail.text = m['EMAIL'];
              txtFacebook.text = m['FACEBOOK'];
              txtTel.text = m['TEL'];
              myPhoto = m['PHOTO'];
              int petat = int.parse(m['ETAT']);
              indexWilaya = int.parse(m['WILAYA']);
              txtWilaya.text = Data.listWilaya[indexWilaya];
              mySpec = Specialite(
                  id: int.parse(m['ID_SPECIALITE']),
                  nbPersons: int.parse(m['NB']),
                  des_ar: m['DESIGNATION_AR'],
                  designation: m['DESIGNATION'],
                  etat: int.parse(m['SETAT']));
              txtSpecialite.text =
                  countryCode == 'ar' ? mySpec!.des_ar : mySpec!.designation;
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
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    double minSize = min(Data.heightScreen, Data.widthScreen) / 2;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
                                        .txtTitreFicheArtisan,
                                    style: GoogleFonts.abel(
                                        color: Colors.brown,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26)),
                                const Spacer(),
                              ]),
                              if (loading || valider) const Spacer(),
                              if (loading)
                                const Center(
                                    child:
                                        CircularProgressIndicator.adaptive()),
                              if (valider)
                                Center(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Text(AppLocalizations.of(context)!
                                          .txtValidationEnCours),
                                      const SizedBox(width: 10),
                                      const CircularProgressIndicator.adaptive()
                                    ])),
                              if (loading || valider) const Spacer(),
                              if (!loading && !valider)
                                Expanded(child: bodyContent(minSize))
                            ])))))));
  }

  bodyContent(double minSize) => Card(
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: ListView(primary: false, shrinkWrap: true, children: [
            const SizedBox(height: 20),
            myPhotos(minSize),
            const SizedBox(height: 20),
            TextField(
                enabled: !valider,
                controller: txtNom,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                    errorText: valNom
                        ? AppLocalizations.of(context)!.txtChampsObligatoire
                        : null,
                    prefixIcon: const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.supervised_user_circle_outlined,
                            color: Colors.black)),
                    contentPadding: const EdgeInsets.only(bottom: 3),
                    labelText: AppLocalizations.of(context)!.txtLibNom,
                    labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    hintText: AppLocalizations.of(context)!.txtLibNom,
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always)),
            const SizedBox(height: 20),
            TextField(
                enabled: !valider,
                controller: txtTel,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 16, color: Colors.green.shade600),
                decoration: InputDecoration(
                    errorText: valTel
                        ? AppLocalizations.of(context)!.txtChampsObligatoire
                        : null,
                    prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.phone, color: Colors.green.shade600)),
                    contentPadding: const EdgeInsets.only(bottom: 3),
                    labelText: AppLocalizations.of(context)!.txtLibTel,
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600),
                    hintText: AppLocalizations.of(context)!.txtLibTel,
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always)),
            const SizedBox(height: 20),
            TextField(
                enabled: !valider,
                controller: txtAdresse,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                    errorText: valAdresse
                        ? AppLocalizations.of(context)!.txtChampsObligatoire
                        : null,
                    prefixIcon: const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.gps_fixed, color: Colors.black)),
                    contentPadding: const EdgeInsets.only(bottom: 3),
                    labelText: AppLocalizations.of(context)!.txtLibAdresse,
                    labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    hintText: AppLocalizations.of(context)!.txtLibAdresse,
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always)),
            const SizedBox(height: 20),
            TextField(
                enabled: !valider,
                controller: txtEmail,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 16, color: Colors.brown),
                decoration: InputDecoration(
                    prefixIcon: Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.email_outlined, color: Colors.brown)),
                    contentPadding: EdgeInsets.only(bottom: 3),
                    labelText: AppLocalizations.of(context)!.txtLibEmail,
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown),
                    hintText: AppLocalizations.of(context)!.txtLibEmail,
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always)),
            const SizedBox(height: 20),
            TextField(
                enabled: !valider,
                controller: txtFacebook,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
                decoration: InputDecoration(
                    prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.facebook_outlined,
                            color: Colors.blue.shade600)),
                    contentPadding: const EdgeInsets.only(bottom: 3),
                    labelText: AppLocalizations.of(context)!.txtLibFacebook,
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600),
                    hintText: AppLocalizations.of(context)!.txtLibFacebook,
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always)),
            const SizedBox(height: 20),
            TextField(
                onTap: () {
                  print("tap on wilaya");
                  selectWilaya();
                },
                enabled: !valider,
                readOnly: true,
                controller: txtWilaya,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                    errorText: valWilaya
                        ? AppLocalizations.of(context)!.txtChampsObligatoire
                        : null,
                    prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.location_city, color: Colors.black)),
                    contentPadding: const EdgeInsets.only(bottom: 3),
                    labelText: AppLocalizations.of(context)!.txtWilaya,
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    hintText: AppLocalizations.of(context)!.txtWilaya,
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always)),
            const SizedBox(height: 20),
            TextField(
                onTap: () {
                  print("tap on specialite");
                  selectSpecialite();
                },
                enabled: !valider,
                readOnly: true,
                controller: txtSpecialite,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                    errorText: valSpecialite
                        ? AppLocalizations.of(context)!.txtChampsObligatoire
                        : null,
                    prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.travel_explore_outlined,
                            color: Colors.black)),
                    contentPadding: const EdgeInsets.only(bottom: 3),
                    labelText: AppLocalizations.of(context)!.txtMetier,
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    hintText: AppLocalizations.of(context)!.txtMetier,
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always)),
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
            Row(children: [
              const Spacer(flex: 3),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: TextButton.icon(
                      onPressed: fnValider,
                      icon: const Icon(Icons.verified_rounded,
                          color: Colors.white),
                      label: Text(AppLocalizations.of(context)!.txtValider,
                          style: TextStyle(color: Colors.white)))),
              const Spacer(flex: 1),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20)),
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
                      icon: const Icon(Icons.cancel_outlined,
                          color: Colors.white),
                      label: Text(AppLocalizations.of(context)!.txtAnnuler,
                          style: TextStyle(color: Colors.white)))),
              const Spacer(flex: 3)
            ]),
            const SizedBox(height: 20)
          ])));

  selectWilaya() {
    txtWilaya.text = "";
    indexWilaya = 0;
    showModalBottomSheet(
        isDismissible: true,
        context: context,
        elevation: 5,
        enableDrag: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SelectAllWilaya();
        }).then((index) {
      if (index != null) {
        indexWilaya = index;
        txtWilaya.text = Data.listWilaya[index];
      }
      setState(() {});
    });
  }

  selectSpecialite() {
    txtSpecialite.text = "";
    mySpec = null;
    showModalBottomSheet(
        isDismissible: true,
        context: context,
        elevation: 5,
        enableDrag: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SelectSpecialite();
        }).then((item) {
      if (item != null) {
        mySpec = item;
        txtSpecialite.text =
            countryCode == 'ar' ? item.des_ar : item.designation;
      }
      setState(() {});
    });
  }

  myPhotos(double minSize) => Center(
      child: InkWell(
          onTap: () async {
            await pickPhoto();
          },
          splashColor: Colors.black26,
          child: Ink(
              height: minSize,
              width: minSize,
              decoration: BoxDecoration(
                  image: DecorationImage(image: drawImage()),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  border: Border.all(color: Colors.black)))));

  drawImage() {
    if (selectPhoto) {
      return FileImage(File(myPhoto));
    } else if (myPhoto.isEmpty) {
      return const AssetImage("images/noPhoto.png");
    } else {
      return NetworkImage(Data.getImage(myPhoto, "ARTISAN"));
    }
  }

  fnValider() async {
    bool continuer = true;
    setState(() {
      valider = true;
      valAdresse = txtAdresse.text.isEmpty;
      valNom = txtNom.text.isEmpty;
      valTel = txtTel.text.isEmpty;
      valWilaya = txtWilaya.text.isEmpty;
      valSpecialite = txtSpecialite.text.isEmpty;
    });
    if (valAdresse || valNom || valTel || valWilaya || valSpecialite) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: AppLocalizations.of(context)!.txtErreur,
              desc: AppLocalizations.of(context)!.txtErrChampsObligatoire)
          .show();
      continuer = false;
    } else if (!selectPhoto && myPhoto.isEmpty) {
      await AwesomeDialog(
              context: context,
              dialogType: DialogType.QUESTION,
              showCloseIcon: true,
              btnOkText: AppLocalizations.of(context)!.txtOui,
              btnOkOnPress: () {},
              btnCancelText: AppLocalizations.of(context)!.txtNon,
              btnCancelOnPress: () {
                continuer = false;
              },
              title: '',
              desc: AppLocalizations.of(context)!.txtQuestionSansPhoto)
          .show();
    }
    if (continuer) {
      print("valider");
      existArtisan();
    } else {
      setState(() {
        valider = false;
      });
    }
  }

  existArtisan() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/EXIST_ARTISAN.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "NOM": txtNom.text,
          "ID_ARTISAN": idArtisan.toString(),
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            int result = 0;
            for (var m in responsebody) {
              result = int.parse(m['ID_ARTISAN']);
            }
            if (result == 0) {
              if (idArtisan == 0) {
                insertArtisan();
              } else {
                updateArtisan();
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

  updateArtisan() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/UPDATE_ARTISAN.php";
    print(url);
    int petat = isSwitched ? 1 : 2;
    String ext = selectPhoto ? p.extension(myPhoto) : "";
    String data =
        selectPhoto ? base64Encode(File(myPhoto).readAsBytesSync()) : "";
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      "ID_ARTISAN": idArtisan.toString(),
      "NOM": txtNom.text.toUpperCase(),
      "TEL": txtTel.text.toUpperCase(),
      "ADRESSE": txtAdresse.text.toUpperCase(),
      "EMAIL": txtEmail.text.toUpperCase(),
      "FACEBOOK": txtFacebook.text.toUpperCase(),
      "ETAT": petat.toString(),
      "ID_SPECIALITE": mySpec!.id.toString(),
      "WILAYA": indexWilaya.toString(),
      "EXT": ext,
      "DATA": data
    }).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("Response=$responsebody");
        if (responsebody != "0") {
          Data.showSnack(
              msg: AppLocalizations.of(context)!.txtSucessUpdate,
              color: Colors.green);
          Data.upData = true;
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

  insertArtisan() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/INSERT_ARTISAN.php";
    print(url);
    int petat = isSwitched ? 1 : 2;
    Uri myUri = Uri.parse(url);
    String ext = selectPhoto ? p.extension(myPhoto) : "";
    String data =
        selectPhoto ? base64Encode(File(myPhoto).readAsBytesSync()) : "";
    http.post(myUri, body: {
      "NOM": txtNom.text.toUpperCase(),
      "TEL": txtTel.text.toUpperCase(),
      "ADRESSE": txtAdresse.text.toUpperCase(),
      "EMAIL": txtEmail.text.toUpperCase(),
      "FACEBOOK": txtFacebook.text.toUpperCase(),
      "ETAT": petat.toString(),
      "ID_SPECIALITE": mySpec!.id.toString(),
      "WILAYA": indexWilaya.toString(),
      "EXT": ext,
      "DATA": data
    }).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("Response=$responsebody");
        if (responsebody != "0") {
          Data.showSnack(
              msg: AppLocalizations.of(context)!.txtLibInscris,
              color: Colors.green);
          Data.upData = true;
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

  pickPhoto() async {
    final ImagePicker picker = ImagePicker();
    final ximage = await picker.pickImage(source: ImageSource.gallery);
    if (ximage == null) return;
    setState(() {
      myPhoto = ximage.path;
      selectPhoto = true;
    });
  }
}
