import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm/classes/specialite.dart';
import 'package:cdm/lists/list_artisans.dart';
import 'package:cdm/auth/admin_login.dart';
import 'package:cdm/classes/data.dart';
import 'package:cdm/l10n/l10n.dart';
import 'package:cdm/provider/local_provider.dart';
import 'package:cdm/widgets/select_specialite.dart';
import 'package:cdm/widgets/select_wilaya.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageAcceuil extends StatefulWidget {
  const PageAcceuil({Key? key}) : super(key: key);

  @override
  State<PageAcceuil> createState() => _PageAcceuilState();
}

class _PageAcceuilState extends State<PageAcceuil> {
  String wilaya = "";
  Specialite? mySpec;
  late var countryCode, provider, locale;
  int indexWilaya = 0;

  Future<bool> _onWillPop() async {
    if (Data.isAdmin) {
      return true;
    } else {
      return (await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      content: Text(
                          AppLocalizations.of(context)!.txtQuestionQuitter),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(AppLocalizations.of(context)!.txtNon,
                                style: TextStyle(color: Colors.red))),
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(AppLocalizations.of(context)!.txtOui,
                                style: TextStyle(color: Colors.green)))
                      ]))) ??
          false;
    }
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    provider = Provider.of<LocalProvider>(context, listen: false);
    locale = provider.locale;
    countryCode = provider.locale?.languageCode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<LocalProvider>(context, listen: false);
    locale = provider.locale;
    countryCode = provider.locale?.languageCode;
    Data.setSizeScreen(context);
    return SafeArea(
        child: WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
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
                            child: ListView(children: [
                              Row(children: [
                                languageWidget(context),
                                const Spacer(),
                                InkWell(
                                    onTap: () {
                                      Data.idAdmin = 0;
                                      var route = MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminLogin());
                                      Navigator.of(context).push(route);
                                    },
                                    child: Ink(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .txtLoginAdmin,
                                            style: GoogleFonts.adamina(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontWeight: FontWeight.bold))))
                              ]),
                              const SizedBox(height: 10),
                              Center(
                                  child: SizedBox(
                                      height: Data.heightScreen / 5,
                                      child: Image.asset("images/CDM.png",
                                          fit: BoxFit.cover))),
                              const SizedBox(height: 10),
                              Center(
                                  child: Text(
                                      AppLocalizations.of(context)!.txtWelcome,
                                      style: GoogleFonts.abel(
                                          color: Colors.brown,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26))),
                              const SizedBox(height: 16),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Data.widthScreen / 10),
                                  child: Wrap(
                                      alignment: WrapAlignment.center,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)!
                                                .txtSujetWelcome,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.abel(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14))
                                      ])),
                              const SizedBox(height: 16),
                              InkWell(
                                  onTap: () => selectWilaya(),
                                  child: Ink(
                                      child: Container(
                                          padding: const EdgeInsets.all(8),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: Data.widthScreen / 9),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: Center(
                                              child: Text(
                                                  wilaya.isEmpty
                                                      ? AppLocalizations.of(context)!
                                                          .txtChoixWilaya
                                                      : wilaya,
                                                  style: GoogleFonts.abel(
                                                      color: wilaya.isEmpty
                                                          ? Colors.grey
                                                          : Colors.black)))))),
                              const SizedBox(height: 4),
                              InkWell(
                                  onTap: () => selectSpecialite(),
                                  child: Ink(
                                      child: Container(
                                          padding: const EdgeInsets.all(8),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: Data.widthScreen / 9),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: Center(
                                              child: Text(
                                                  (mySpec == null)
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .txtChoixMetier
                                                      : countryCode == 'ar'
                                                          ? mySpec!.des_ar
                                                          : mySpec!.designation,
                                                  style: GoogleFonts.abel(
                                                      color: mySpec == null
                                                          ? Colors.grey
                                                          : Colors.black)))))),
                              const SizedBox(height: 16),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 12),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: Data.widthScreen / 9),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Colors.red.shade900,
                                        Colors.orange.shade500,
                                        Colors.red.shade900
                                      ]),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25))),
                                  child: InkWell(
                                      onTap: () {
                                        fnSearch();
                                      },
                                      child: Ink(
                                          child: Center(
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .txtStart,
                                                  style: GoogleFonts.abel(
                                                      fontSize: 26,
                                                      color: Colors.white))))))
                            ])))))));
  }

  selectWilaya() {
    wilaya = "";
    indexWilaya = 0;
    setState(() {});
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
        indexWilaya = index;
        setState(() {
          wilaya = Data.listWilaya[index];
        });
      }
    });
  }

  selectSpecialite() {
    mySpec = null;
    setState(() {});
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
        setState(() {});
      }
    });
  }

  fnSearch() {
    if (wilaya.isEmpty || mySpec == null) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: AppLocalizations.of(context)!.txtErreur,
              desc: AppLocalizations.of(context)!.txtErrAcceuil)
          .show();
    } else {
      print("valider");
      var route = MaterialPageRoute(
          builder: (context) =>
              ListArtisans(mySpec: mySpec, indWilaya: indexWilaya));
      Navigator.of(context).push(route).then((value) => setState(() {}));
    }
  }

  Row languageWidget(BuildContext context) => Row(children: [
        Text(AppLocalizations.of(context)!.txtLangue),
        DropdownButtonHideUnderline(
            child: DropdownButton(
                value: locale,
                icon: Container(width: 12),
                items: L10n.all.map(
                  (locale) {
                    final lang = L10n.getLanguage(locale.languageCode);
                    return DropdownMenuItem(
                        child: Text(lang),
                        value: locale,
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          print(locale.languageCode);
                          prefs.setString('Langue', locale.languageCode);
                          final provider = Provider.of<LocalProvider>(context,
                              listen: false);
                          provider.setLocale(locale);
                          setState(() {});
                        });
                  },
                ).toList(),
                onChanged: (_) {}))
      ]);
}
