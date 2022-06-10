// ignore_for_file: avoid_print

import 'package:cdm/auth/user_login.dart';
import 'package:cdm/classes/data.dart';
import 'package:cdm/classes/specialite.dart';
import 'package:cdm/widgets/info_artisan.dart';
import 'package:cdm/classes/artisan.dart';
import 'package:cdm/fiches/fiche_artisan.dart';
import 'package:cdm/provider/local_provider.dart';
import 'package:cdm/widgets/select_specialite.dart';
import 'package:cdm/widgets/select_wilaya.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:provider/provider.dart';

class ListArtisans extends StatefulWidget {
  final Specialite? mySpec;
  final int indWilaya;
  const ListArtisans({Key? key, required this.mySpec, required this.indWilaya})
      : super(key: key);

  @override
  State<ListArtisans> createState() => _ListArtisansState();
}

class _ListArtisansState extends State<ListArtisans> {
  late int indWilaya;
  late String wilaya = "";
  Specialite? mySpec;
  bool isSwitchedWilaya = false, isSwitchedMetier = false;
  bool loading = true, error = false;
  List<Artisan> artisans = [], allArtisans = [];
  TextEditingController txtRecherche = TextEditingController(text: "");
  late final countryCode, provider;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    mySpec = widget.mySpec;
    indWilaya = widget.indWilaya;
    isSwitchedWilaya = (indWilaya < 0);
    isSwitchedMetier = (mySpec == null);
    if (indWilaya >= 0) {
      wilaya = Data.listWilaya[indWilaya];
    }
    provider = Provider.of<LocalProvider>(context, listen: false);
    countryCode = provider.locale?.languageCode;
    getArtisan();
    super.initState();
  }

  getArtisan() async {
    setState(() {
      loading = true;
      error = false;
    });
    allArtisans.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_ARTISAN.php";
    print("url=$url");
    var body = {};
    if (mySpec != null) {
      body['ID_SPECIALITE'] = mySpec!.id.toString();
    }
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: body)
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        Artisan a;
        for (var m in responsebody) {
          a = Artisan(
            etat: 1,
            adress: m['ADRESSE'],
            photo: m['PHOTO'],
            email: m['EMAIL'],
            facebook: m['FACEBOOK'],
            tel: m['TEL'],
            nom: m['NOM'],
            designation: m['DESIGNATION'],
            des_ar: m['DESIGNATION_AR'],
            rate: 3,
            idArtisan: int.parse(m['ID_ARTISAN']),
            wilaya: int.parse(m['WILAYA']),
            idSpecialite: int.parse(m['ID_SPECIALITE']),
          );
          allArtisans.add(a);
        }
        setState(() {
          loading = false;
        });
      } else {
        allArtisans.clear();
        loading = false;
        error = true;
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
      allArtisans.clear();
      loading = false;
      error = true;
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

  getMylist() {
    artisans.clear();
    for (var a in allArtisans) {
      if ((indWilaya < 0 || indWilaya == a.wilaya) &&
          (mySpec == null ||
              mySpec!.des_ar == a.des_ar ||
              mySpec!.designation == a.designation) &&
          (txtRecherche.text.isEmpty ||
              a.nom.toUpperCase().contains(txtRecherche.text.toUpperCase())))
        artisans.add(a);
    }
  }

  @override
  Widget build(BuildContext context) {
    Data.myContext = context;
    Data.setSizeScreen(context);
    getMylist();
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                drawer: Drawer(child: myDrawer(context)),
                floatingActionButton: !Data.isAdmin
                    ? null
                    : FloatingActionButton(
                        child: const Icon(Icons.add),
                        onPressed: () {
                          var route = MaterialPageRoute(
                              builder: (context) => FicheArtisan(idArtisan: 0));
                          Navigator.of(context).push(route).then((value) {
                            getArtisan();
                          });
                        }),
                body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage("images/artisan_opacity.png"))),
                    child: Center(child: Builder(builder: (context) {
                      return Container(
                          constraints: BoxConstraints(maxWidth: Data.maxWidth),
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
                              InkWell(
                                  onTap: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  child: Ink(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.filter_alt_outlined,
                                          color: Colors.amber.shade900))),
                              const Spacer(),
                              Text(
                                  AppLocalizations.of(context)!
                                      .txtTitreArtisans,
                                  style: GoogleFonts.abel(
                                      color: Colors.brown,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26)),
                              const Spacer(),
                              InkWell(
                                  onTap: () {
                                    getArtisan();
                                  },
                                  child: Ink(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.refresh)))
                            ]),
                            const SizedBox(height: 10),
                            if (loading) const Spacer(),
                            if (loading)
                              Center(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    Text(AppLocalizations.of(context)!
                                        .txtConnexionEnCours),
                                    const SizedBox(width: 10),
                                    const CircularProgressIndicator.adaptive()
                                  ])),
                            if (loading || (!loading && artisans.isEmpty))
                              const Spacer(),
                            if (!loading && artisans.isEmpty)
                              Center(
                                  child: Text(
                                      error
                                          ? AppLocalizations.of(context)!
                                              .txtProblemeServeur
                                          : AppLocalizations.of(context)!
                                              .txtListeVide,
                                      style: TextStyle(
                                          color:
                                              error ? Colors.red : Colors.black,
                                          fontSize: error ? 26 : 22,
                                          fontWeight: error
                                              ? FontWeight.bold
                                              : FontWeight.normal))),
                            if (!loading && artisans.isEmpty) const Spacer(),
                            if (!loading && artisans.isNotEmpty) searchBar(),
                            if (!loading && artisans.isNotEmpty) bodyContent(),
                          ]));
                    }))))));
  }

  Material myDrawer(BuildContext context) {
    return Material(
        color: Colors.amber.shade800,
        child: ListView(children: [
          const SizedBox(height: 10),
          if (!Data.isAdmin)
            Center(
                child: Text(AppLocalizations.of(context)!.txtChoixWilaya,
                    style: const TextStyle(color: Colors.black))),
          if (Data.isAdmin) const SizedBox(height: 20),
          if (Data.isAdmin)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Switch(
                  value: isSwitchedWilaya,
                  onChanged: (value) {
                    isSwitchedWilaya = !isSwitchedWilaya;
                    if (isSwitchedWilaya) {
                      wilaya = "";
                      indWilaya = -1;
                    } else {
                      selectWilaya();
                    }
                    setState(() {});
                  }),
              const SizedBox(width: 5),
              Text(
                  isSwitchedWilaya
                      ? AppLocalizations.of(context)!.txAllWilaya
                      : AppLocalizations.of(context)!.txtChoixWilaya,
                  style: const TextStyle(color: Colors.black))
            ]),
          InkWell(
              onTap: () {
                if (!isSwitchedWilaya) {
                  selectWilaya();
                }
              },
              child: Ink(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey)),
                      child: Center(
                          child: Text(
                              isSwitchedWilaya
                                  ? AppLocalizations.of(context)!.txAllWilaya
                                  : wilaya.isEmpty
                                      ? AppLocalizations.of(context)!
                                          .txtChoixWilaya
                                      : wilaya,
                              style: GoogleFonts.abel(
                                  color: wilaya.isEmpty
                                      ? Colors.grey
                                      : Colors.black)))))),
          Padding(
              padding: const EdgeInsets.all(18.0),
              child: const Divider(color: Colors.black)),
          if (!Data.isAdmin)
            Center(
                child: Text(AppLocalizations.of(context)!.txtChoixMetier,
                    style: const TextStyle(color: Colors.black))),
          if (Data.isAdmin) const SizedBox(height: 20),
          if (Data.isAdmin)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Switch(
                  value: isSwitchedMetier,
                  onChanged: (value) {
                    isSwitchedMetier = !isSwitchedMetier;
                    if (isSwitchedMetier) {
                      mySpec = null;
                    } else {
                      selectMetier();
                    }
                    getArtisan();
                  }),
              const SizedBox(width: 5),
              Text(
                  isSwitchedMetier
                      ? AppLocalizations.of(context)!.txAllMetier
                      : AppLocalizations.of(context)!.txtChoixMetier,
                  style: const TextStyle(color: Colors.black))
            ]),
          InkWell(
              onTap: () {
                if (!isSwitchedMetier) {
                  selectMetier();
                }
              },
              child: Ink(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey)),
                      child: Center(
                          child: Text(
                              isSwitchedMetier
                                  ? AppLocalizations.of(context)!.txAllMetier
                                  : mySpec == null
                                      ? AppLocalizations.of(context)!
                                          .txtChoixMetier
                                      : countryCode == 'ar'
                                          ? mySpec!.des_ar
                                          : mySpec!.designation.toUpperCase(),
                              style: GoogleFonts.abel(
                                  color: mySpec == null
                                      ? Colors.grey
                                      : Colors.black))))))
        ]));
  }

  selectWilaya() {
    showModalBottomSheet(
        isDismissible: true,
        context: context,
        elevation: 5,
        enableDrag: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SelectWilaya();
        }).then((index) {
      if (index != null) {
        indWilaya = index;
        wilaya = Data.listWilaya[index];
        setState(() {});
        Navigator.pop(context);
      } else if (!isSwitchedWilaya && Data.isAdmin) {
        isSwitchedWilaya = true;
      }
    });
  }

  selectMetier() {
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
        Navigator.pop(context);
        getArtisan();
      } else if (!isSwitchedMetier && Data.isAdmin) {
        isSwitchedMetier = true;
      }
    });
  }

  Padding searchBar() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: TextField(
            onChanged: (value) {
              if (!loading) {
                setState(() {});
              }
            },
            maxLines: 1,
            controller: txtRecherche,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            decoration: InputDecoration(
                border: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 2.0)),
                focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 3.0)),
                fillColor: Colors.grey.withOpacity(0.2),
                filled: true,
                prefixIcon: const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.search, color: Colors.black)),
                contentPadding: const EdgeInsets.only(bottom: 3),
                labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                hintText: AppLocalizations.of(context)!.txtLibRecherche,
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                floatingLabelBehavior: FloatingLabelBehavior.always)));
  }

  Widget bodyContent() => Expanded(
      child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListView.builder(
              shrinkWrap: true,
              primary: true,
              itemCount: artisans.length,
              itemBuilder: (context, i) => Visibility(
                  visible: (indWilaya < 0 || indWilaya == artisans[i].wilaya) &&
                      (mySpec == null ||
                          mySpec!.des_ar == artisans[i].des_ar ||
                          mySpec!.designation == artisans[i].designation) &&
                      (txtRecherche.text.isEmpty ||
                          artisans[i]
                              .nom
                              .toUpperCase()
                              .contains(txtRecherche.text.toUpperCase())),
                  child: myItem(i, context)))));

  Widget myItem(int i, BuildContext context) => InkWell(
      onTap: () {
        Artisan item = artisans[i];
        print("click on ${item.nom}");
        showModalBottomSheet(
            context: context,
            elevation: 5,
            enableDrag: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return InfoArtisan(personne: item, idSpec: item.idSpecialite);
            }).then((value) {
          if (Data.upData) {
            getArtisan();
            Data.upData = false;
          }
        });
      },
      child: Card(
          elevation: 8,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: myPicture(i),
                title: Center(
                    child: Text(artisans[i].nom,
                        style: GoogleFonts.laila(fontWeight: FontWeight.bold))),
                subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.location_city, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(Data.listWilaya[artisans[i].wilaya],
                            style: const TextStyle(color: Colors.black))
                      ]),
                      Row(children: [
                        const Icon(Icons.travel_explore_outlined,
                            color: Colors.black),
                        const SizedBox(width: 5),
                        Text(
                            countryCode == 'ar'
                                ? artisans[i].des_ar
                                : artisans[i].designation.toUpperCase(),
                            style: const TextStyle(color: Colors.black))
                      ])
                    ])),
            likeBar(i)
          ])));

  Container likeBar(int i) {
    return Container(
        padding: EdgeInsets.all(8),
        color: Colors.grey.shade200,
        child: Row(children: [
          InkWell(
              onTap: () {
                print("i like $i");
                like(i);
              },
              child: Ink(
                  padding: EdgeInsets.all(2),
                  child:
                      Icon(Icons.thumb_up_alt_outlined, color: Colors.green))),
          const SizedBox(width: 20),
          InkWell(
              onTap: () {
                print("i dislike $i");
              },
              child: Ink(
                  padding: EdgeInsets.all(2),
                  child:
                      Icon(Icons.thumb_down_alt_outlined, color: Colors.red))),
          const SizedBox(width: 20),
          InkWell(
              onTap: () {
                print("i comment $i");
              },
              child: Ink(
                  padding: EdgeInsets.all(2),
                  child:
                      Icon(Icons.mode_comment_outlined, color: Colors.blue))),
          const Spacer(),
          Data.rateWidget(item: artisans[i], size: 20)
        ]));
  }

  like(int i) {
    if (Data.idUser == 0) {
      authentification();
    } else {}
  }

  authentification() {
    Data.idAdmin = 0;
    var route = MaterialPageRoute(builder: (context) => const UserLogin());
    Navigator.of(context).push(route);
  }

  SizedBox myPicture(int i) => SizedBox(
      width: 60,
      child: (artisans[i].photo == "")
          ? Image.asset("images/noPhoto.png")
          : CachedNetworkImage(
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                      color: Data.darkColor[
                          Random().nextInt(Data.darkColor.length - 1) + 1])),
              imageUrl: Data.getImage(artisans[i].photo, "ARTISAN")));
}
