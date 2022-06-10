import 'dart:math';
import 'package:cdm/classes/data.dart';
import 'package:cdm/widgets/info_specialite.dart';
import 'package:cdm/classes/specialite.dart';
import 'package:cdm/fiches/fiche_specialite.dart';
import 'package:cdm/lists/list_artisans.dart';
import 'package:cdm/provider/local_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:provider/provider.dart';

class ListSpecialite extends StatefulWidget {
  const ListSpecialite({Key? key}) : super(key: key);

  @override
  State<ListSpecialite> createState() => _ListSpecialiteState();
}

class _ListSpecialiteState extends State<ListSpecialite> {
  bool loading = true, error = false;
  List<Specialite> specs = [];
  int nbTotal = 0;
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
    nbTotal = 0;
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
              if (Data.isAdmin || e.etat == 1) {
                specs.add(e);
                nbTotal += e.nbPersons;
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
    Data.myContext = context;
    Data.setSizeScreen(context);
    double minSize = min(Data.heightScreen, Data.widthScreen) / 2 + 20;
    Specialite s = Specialite(
        des_ar: "جميع المهن",
        designation: countryCode == "en" ? "All" : "Tous",
        etat: 1,
        id: 0,
        nbPersons: nbTotal);
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                floatingActionButton: !Data.isAdmin
                    ? null
                    : FloatingActionButton(
                        tooltip: AppLocalizations.of(context)!.txtInsertMetier,
                        child: const Icon(Icons.add),
                        onPressed: () {
                          var route = MaterialPageRoute(
                              builder: (context) =>
                                  const FicheSpecialite(idSpecialite: 0));
                          Navigator.of(context)
                              .push(route)
                              .then((value) => getListSpecialite());
                        }),
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
                            child: bodyContent(context, s, minSize)))))));
  }

  Column bodyContent(BuildContext context, Specialite s, double minSize) {
    return Column(children: [
      Row(children: [
        InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child:
                Ink(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_back))),
        const Spacer(),
        Text(AppLocalizations.of(context)!.txtTitreSpecialite,
            style: GoogleFonts.abel(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 26)),
        const Spacer(),
        InkWell(
            onTap: () {
              getListSpecialite();
            },
            child: Ink(padding: EdgeInsets.all(8), child: Icon(Icons.refresh)))
      ]),
      const SizedBox(height: 10),
      if (loading) const Spacer(),
      if (loading)
        Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(AppLocalizations.of(context)!.txtConnexionEnCours),
          const SizedBox(width: 10),
          const CircularProgressIndicator.adaptive()
        ])),
      if (loading || (!loading && specs.isEmpty)) const Spacer(),
      if (!loading && specs.isEmpty)
        Center(
            child: Text(
                error
                    ? AppLocalizations.of(context)!.txtProblemeServeur
                    : AppLocalizations.of(context)!.txtListeVide,
                style: TextStyle(
                    color: error ? Colors.red : Colors.black,
                    fontSize: error ? 26 : 22,
                    fontWeight: error ? FontWeight.bold : FontWeight.normal))),
      if (!loading && specs.isEmpty) const Spacer(),
      if (!loading && specs.isNotEmpty) myItem(s),
      if (!loading && specs.isNotEmpty) listOfItems(minSize)
    ]);
  }

  Widget myItem(Specialite item) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
        child: InkWell(
            onTap: () {
              print("click on ${item.designation}");
              var route = MaterialPageRoute(
                  builder: (context) => ListArtisans(
                      mySpec: item.id > 0 ? item : null, indWilaya: -1));
              Navigator.of(context)
                  .push(route)
                  .then((value) => getListSpecialite());
            },
            splashColor: Colors.black26,
            child: Ink(
                child: Card(
                    elevation: 8,
                    child: Container(
                        color: item.id == 0
                            ? Colors.orange.shade100
                            : item.etat == 1
                                ? Colors.blue.shade100
                                : Colors.grey.shade300.withOpacity(0.9),
                        child: ListTile(
                            leading: Visibility(
                                visible: Data.isAdmin && item.id != 0,
                                child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          elevation: 5,
                                          enableDrag: true,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) {
                                            return InfoSpecialite(spec: item);
                                          }).then((value) {
                                        getListSpecialite();
                                      });
                                    },
                                    child: Ink(child: Icon(Icons.menu)))),
                            title: Text(countryCode == 'ar'
                                ? item.des_ar
                                : item.designation),
                            trailing: Text(item.nbPersons.toString() +
                                " " +
                                AppLocalizations.of(context)!
                                    .txtLibInscris)))))));
  }

  Widget listOfItems(double minSize) => Expanded(
          child: ListView(children: [
        Center(
            child: Wrap(
                children: specs
                    .map((item) {
                      return myItem(item);
                    })
                    .toList()
                    .cast<Widget>()))
      ]));
}
