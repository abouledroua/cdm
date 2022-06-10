import 'package:cdm/acceuil/acceuil.dart';
import 'package:cdm/widgets/changer_code_access.dart';
import 'package:cdm/classes/data.dart';
import 'package:cdm/lists/list_specialites.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AcceuilAdmin extends StatefulWidget {
  const AcceuilAdmin({Key? key}) : super(key: key);

  @override
  State<AcceuilAdmin> createState() => _AcceuilAdminState();
}

class _AcceuilAdminState extends State<AcceuilAdmin> {
  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    content:
                        Text(AppLocalizations.of(context)!.txtQuestionQuitter),
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

  @override
  initState() {
    WidgetsFlutterBinding.ensureInitialized();
    if (!Data.isAdmin) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ListSpecialite()),
          (Route<dynamic> route) => false);
    } else {
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    Data.myContext = context;
    Data.setSizeScreen(context);
    return SafeArea(
        child: WillPopScope(
            onWillPop: _onWillPop,
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
                            padding: const EdgeInsets.all(8),
                            child: bodyContent()))))));
  }

  bodyContent() => Center(
          child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text(AppLocalizations.of(context)!.txtTitreAdmin,
              style: GoogleFonts.abel(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 26))
        ]),
        Spacer(flex: 4),
        InkWell(
            onTap: () {
              var route = MaterialPageRoute(
                  builder: (context) => const ListSpecialite());
              Navigator.of(context)
                  .push(route)
                  .then((value) => setState(() {}));
            },
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Ink(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const Icon(Icons.bookmarks,
                          color: Colors.amber, size: 38),
                      const SizedBox(width: 20),
                      Expanded(
                          child: Center(
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .txtTitreSpecialite,
                                  style: GoogleFonts.laila(
                                      color: Colors.amber,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold))))
                    ])))),
        Spacer(flex: 1),
        InkWell(
            onTap: () {
              showModalBottomSheet(
                  isDismissible: false,
                  context: context,
                  elevation: 5,
                  enableDrag: true,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return ChangeAccessCode();
                  });
            },
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Ink(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const Icon(Icons.key, color: Colors.grey, size: 38),
                      const SizedBox(width: 20),
                      Expanded(
                          child: Center(
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .txtModifCodeAccess,
                                  style: GoogleFonts.laila(
                                      color: Colors.grey,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold))))
                    ])))),
        Spacer(flex: 1),
        InkWell(
            onTap: () {
              Data.isAdmin = false;
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                      maintainState: true,
                      opaque: true,
                      pageBuilder: (context, _, __) => const PageAcceuil(),
                      transitionDuration: const Duration(seconds: 2),
                      transitionsBuilder: (context, anim1, anim2, child) {
                        return FadeTransition(opacity: anim1, child: child);
                      }));
            },
            child: Ink(
                padding: const EdgeInsets.all(16),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.logout_outlined,
                      color: Colors.red, size: 38),
                  const SizedBox(width: 20),
                  Expanded(
                      child: Center(
                          child: Text(AppLocalizations.of(context)!.txtlogout,
                              style: GoogleFonts.laila(
                                  color: Colors.red,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold))))
                ]))),
        Spacer(flex: 4)
      ]));
}
