import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm/acceuil/admin_acceuil.dart';
import 'package:cdm/classes/data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  TextEditingController txtPassword = TextEditingController(text: "");
  String password = "";
  bool showPassword = false, loading = false;
  int nbTry = 0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    nbTry = 0;
    loading = false;
    Data.isAdmin = false;
    if (Data.production) {
      txtPassword.text = "";
      password = "";
    }
    super.initState();
  }

  getCode() async {
    setState(() {
      loading = true;
    });
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_CODE_ACCESS.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"CODE": txtPassword.text.toUpperCase()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            Data.idAdmin = 0;
            for (var m in responsebody) {
              Data.idAdmin = int.parse(m['ID_ADMIN']);
            }
            if (Data.idAdmin != 0) {
              Data.isAdmin = true;
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AcceuilAdmin()),
                  (Route<dynamic> route) => false);
            } else {
              Data.isAdmin = false;
              nbTry++;
              AwesomeDialog(
                      context: context,
                      dialogType: DialogType.ERROR,
                      showCloseIcon: true,
                      title: AppLocalizations.of(context)!.txtErreur,
                      desc: AppLocalizations.of(context)!.txtProblemeCodeAccess)
                  .show()
                  .then((value) {
                if (nbTry == 3) {
                  Navigator.pop(context);
                } else {
                  setState(() {
                    txtPassword.text = "";
                    password = "";
                  });
                }
              });
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
                                    AppLocalizations.of(context)!.txtTitreLogin,
                                    style: GoogleFonts.abel(
                                        color: Colors.brown,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26)),
                                const Spacer()
                              ]),
                              const SizedBox(height: 10),
                              Center(
                                  child: SizedBox(
                                      height: Data.heightScreen / 5,
                                      child: Image.asset("images/CDM.png",
                                          fit: BoxFit.cover))),
                              const SizedBox(height: 10),
                              if (loading) const Spacer(),
                              if (loading)
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(AppLocalizations.of(context)!
                                          .txtConnexionEnCours),
                                      const SizedBox(width: 10),
                                      const CircularProgressIndicator.adaptive()
                                    ]),
                              if (loading) const Spacer(),
                              if (!loading) Expanded(child: bodyContent())
                            ])))))));
  }

  Widget bodyContent() => ListView(children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: txtPassword,
                onChanged: (value) => password = value,
                obscureText: !showPassword,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        icon: const Icon(Icons.remove_red_eye,
                            color: Colors.black)),
                    hintText: AppLocalizations.of(context)!.txtCodeAccess,
                    floatingLabelBehavior: FloatingLabelBehavior.always))),
        const SizedBox(height: 20),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            margin: EdgeInsets.symmetric(horizontal: Data.widthScreen / 9),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.red.shade900,
                  Colors.orange.shade500,
                  Colors.red.shade900
                ]),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: InkWell(
                onTap: () async {
                  await getCode();
                },
                child: Ink(
                    child: Center(
                        child: Text(
                            AppLocalizations.of(context)!.txtbtnConnecter,
                            style: GoogleFonts.abel(
                                fontSize: 26, color: Colors.white))))))
      ]);
}
