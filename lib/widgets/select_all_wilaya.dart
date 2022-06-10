import 'dart:math';

import 'package:cdm/classes/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectAllWilaya extends StatefulWidget {
  const SelectAllWilaya({Key? key}) : super(key: key);

  @override
  State<SelectAllWilaya> createState() => _SelectAllWilayaState();
}

class _SelectAllWilayaState extends State<SelectAllWilaya> {
  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: Data.maxWidth),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25))),
                margin: EdgeInsets.only(
                    left: min(Data.widthScreen, Data.heightScreen) / 15,
                    right: min(Data.widthScreen, Data.heightScreen) / 15,
                    top: min(Data.widthScreen, Data.heightScreen) / 15,
                    bottom: min(Data.widthScreen, Data.heightScreen) / 15),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.orange.shade300,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!
                                .txtErrSearchWilaya)
                          ])),
                  Expanded(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Wrap(
                              children: Data.listWilaya
                                  .map((item) {
                                    return InkWell(
                                        onTap: () {
                                          int index =
                                              Data.listWilaya.indexOf(item);
                                          print("selected wilaya $item");
                                          Navigator.of(context).pop(index);
                                        },
                                        child: Ink(
                                            padding: EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                bottom: 10 +
                                                    MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom),
                                            child:
                                                ListTile(title: Text(item))));
                                  })
                                  .toList()
                                  .cast<Widget>())))
                ]))));
  }
}
