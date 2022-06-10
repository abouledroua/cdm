// ignore_for_file: avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm/classes/data.dart';
import 'package:cdm/classes/artisan.dart';
import 'package:cdm/fiches/fiche_artisan.dart';
import 'package:cdm/provider/local_provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class InfoArtisan extends StatefulWidget {
  final int idSpec;
  final Artisan personne;
  const InfoArtisan({Key? key, required this.personne, required this.idSpec})
      : super(key: key);

  @override
  State<InfoArtisan> createState() => _InfoArtisanState();
}

class _InfoArtisanState extends State<InfoArtisan> {
  late int idSpecialite;
  late Artisan item;
  late final countryCode, provider;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    item = widget.personne;
    Data.upData = false;
    idSpecialite = widget.idSpec;
    provider = Provider.of<LocalProvider>(context, listen: false);
    countryCode = provider.locale?.languageCode;
    super.initState();
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(onTap: () {}, child: child));

  @override
  Widget build(BuildContext context) {
    return makeDismissible(
        child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (_, controller) => SafeArea(
                child: Center(
                    child: Container(
                        constraints: BoxConstraints(maxWidth: Data.maxWidth),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25))),
                        padding: const EdgeInsets.all(10),
                        child: ListView(controller: controller, children: [
                          Text(item.nom.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.laila(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.clip),
                          //      Data.rateWidget(item: item, size: 32),
                          circularPhoto(),
                          myinfos(
                              icon: Icons.location_city,
                              text: Data.listWilaya[item.wilaya],
                              color: Colors.black),
                          myinfos(
                              icon: Icons.travel_explore_outlined,
                              color: Colors.black,
                              text: countryCode == 'ar'
                                  ? item.des_ar
                                  : item.designation.toUpperCase()),
                          if (item.adress != "")
                            myinfos(
                                icon: Icons.gps_fixed,
                                text: item.adress,
                                color: Colors.black),
                          if (item.tel != "")
                            myinfos(
                                icon: Icons.phone,
                                text: item.tel,
                                color: Colors.green),
                          if (item.email != "")
                            myinfos(
                                icon: Icons.email_outlined,
                                text: item.email,
                                color: Colors.brown),
                          if (item.facebook != "")
                            myinfos(
                                icon: Icons.facebook,
                                text: item.facebook,
                                color: Colors.blue.shade600),
                          const Divider(),
                          Wrap(alignment: WrapAlignment.spaceEvenly, children: [
                            if (item.tel != "")
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                      onPrimary: Colors.white),
                                  onPressed: () {
                                    Data.makeExternalRequest("tel:${item.tel}");
                                  },
                                  icon: const Icon(Icons.call_outlined),
                                  label: Text(AppLocalizations.of(context)!
                                      .txtAppeler)),
                            if (item.tel != "")
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueAccent,
                                      onPrimary: Colors.white),
                                  onPressed: () {
                                    Data.makeExternalRequest("sms:${item.tel}");
                                  },
                                  icon: const Icon(Icons.sms_outlined),
                                  label: Text(
                                      AppLocalizations.of(context)!.txtSMS)),
                            if (item.email != "")
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.brown,
                                      onPrimary: Colors.white),
                                  onPressed: () {
                                    final Uri params = Uri(
                                        scheme: 'mailto',
                                        path: item.email,
                                        query:
                                            'subject=App Feedback&body=App Version 3.23');
                                    var url = params.toString();
                                    Data.makeExternalRequest(url);
                                  },
                                  icon: const Icon(Icons.email_outlined),
                                  label: Text(AppLocalizations.of(context)!
                                      .txtSendEmail)),
                            if (item.facebook != "")
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blue.shade800,
                                      onPrimary: Colors.white),
                                  onPressed: () {
                                    Data.makeExternalRequest(
                                        "https://facebook.com/${item.facebook}");
                                  },
                                  icon: const Icon(Icons.facebook_outlined),
                                  label: Text(AppLocalizations.of(context)!
                                      .txtLibFacebook))
                          ]),
                          if (Data.isAdmin) const Divider(),
                          const SizedBox(height: 22),
                          if (Data.isAdmin)
                            Wrap(
                                alignment: WrapAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.green,
                                          onPrimary: Colors.white),
                                      onPressed: () {
                                        var route = MaterialPageRoute(
                                            builder: (context) => FicheArtisan(
                                                idArtisan: item.idArtisan));
                                        Navigator.of(context).push(route).then(
                                            (value) => Navigator.pop(context));
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: Text(AppLocalizations.of(context)!
                                          .txtModifier)),
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.red,
                                          onPrimary: Colors.white),
                                      onPressed: () {
                                        AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType.QUESTION,
                                                showCloseIcon: true,
                                                btnOkText: AppLocalizations.of(
                                                        context)!
                                                    .txtOui,
                                                btnOkOnPress: () async {
                                                  await deleteClient();
                                                },
                                                btnCancelText:
                                                    AppLocalizations.of(
                                                            context)!
                                                        .txtNon,
                                                btnCancelOnPress: () {},
                                                title: '',
                                                desc: AppLocalizations.of(
                                                        context)!
                                                    .txtQuestionDelete)
                                            .show();
                                      },
                                      icon: const Icon(Icons.delete),
                                      label: Text(AppLocalizations.of(context)!
                                          .txtSupprimer))
                                ])
                        ]))))));
  }

  myinfos(
          {required IconData icon,
          required String text,
          required Color color}) =>
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2),
          child: Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 20),
            Text(text, style: TextStyle(color: color))
          ]));

  deleteClient() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/DELETE_ARTISAN.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_ARTISAN": item.idArtisan.toString()})
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

  Widget circularPhoto() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 130,
        height: 130,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: showPhoto(), fit: BoxFit.contain)));
  }

  showPhoto() {
    if (item.photo == "") {
      return const AssetImage("images/noPhoto.png");
    } else {
      return CachedNetworkImageProvider(Data.getImage(item.photo, "ARTISAN"));
    }
  }
}
