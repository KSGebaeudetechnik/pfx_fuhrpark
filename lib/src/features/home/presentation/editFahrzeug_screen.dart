import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pfx_fuhrpark/src/features/home/objects/fahrzeug.dart';
import 'package:intl/intl.dart';

class EditFahrzeugScreen extends StatefulWidget {
  Fahrzeug diesesFahrzeug;
  EditFahrzeugScreen({super.key, required Fahrzeug this.diesesFahrzeug});

  @override
  State<EditFahrzeugScreen> createState() => _EditFahrzeugScreenState();
}

class _EditFahrzeugScreenState extends State<EditFahrzeugScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBar: PreferredSize(
        preferredSize: const Size(392.7, 110.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 55.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  width: 20.0,
                ),
                GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Theme.of(context).colorScheme.onSecondary,
                    size: 30,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.diesesFahrzeug.caption ??
                            "Unbekannter Fahrzeugname",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(width: 15.0),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 35.0,
                          height: 35.0,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Row(children: [
              SizedBox(
                height: 1.0,
              )
            ]),
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18.0)),
              ),
              color: Colors.white,
              elevation: 0.0,
              child: SizedBox(
                width: 314,
                height: 225,
                child: Column(
                  children: [
                    SizedBox(height: 40.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),

                                /// Condition for which image shall be displayed
                                child: (null != null)
                                    ? Container(
                                        height: 150.0,
                                        width: 150.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: FileImage(widget
                                                  .diesesFahrzeug.name as File),
                                              fit: BoxFit.cover),
                                        ),
                                      )
                                    : widget.diesesFahrzeug.typNummer == "2" ||
                                    widget.diesesFahrzeug.typNummer == "1" ||
                                    widget.diesesFahrzeug.typNummer == "4" ||
                                    widget.diesesFahrzeug.typNummer == null
                                    ? ClipRRect(
                                  borderRadius:
                                  const BorderRadius.vertical(
                                      top: Radius.circular(100.0)),
                                  child: Image.asset(
                                    'assets/images/pkw.png',
                                    width: 130,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : widget.diesesFahrzeug.typNummer == "3"
                                    ? ClipRRect(
                                  borderRadius:
                                  const BorderRadius.vertical(
                                      top: Radius.circular(100.0)),
                                  child: Image.asset(
                                    'assets/images/lkw.png',
                                    width: 130,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : ClipRRect(
                                  borderRadius:
                                  const BorderRadius.vertical(
                                      top: Radius.circular(100.0)),
                                  child: Image.asset(
                                    'assets/images/anhaenger.png',
                                    width: 130,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 35.0),
                    Text(
                      widget.diesesFahrzeug.name ?? "Unbekanntes Kennzeichen",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18.0)),
              ),
              color: Colors.white,
              elevation: 0.0,
              child: SizedBox(
                width: 314,
                height: 250,
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // = size of icon on the right
                              Text(
                                "Informationen",
                                style: Theme.of(context).textTheme.displayLarge,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Fahrzeugtyp",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            "${widget.diesesFahrzeug.typ}",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child:
                      Divider(color: Theme.of(context).colorScheme.outline),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tankstand",
                            style: TextStyle(color: Colors.black),
                          ),
                          widget.diesesFahrzeug.fuelLevel == null
                              ? Text(
                                  "--",
                                  style: TextStyle(color: Colors.black),
                                )
                              : widget.diesesFahrzeug.fuelLevel! < 15
                          ? Text(
                                  "${widget.diesesFahrzeug.fuelLevel!.toInt()} %",
                                  style: TextStyle(color: Colors.red),
                                )
                              : widget.diesesFahrzeug.fuelLevel! < 30
                          ? Text(
                              "${widget.diesesFahrzeug.fuelLevel!.toInt()} %",
                              style: TextStyle(color: Colors.amber))
                              : Text(
                              "${widget.diesesFahrzeug.fuelLevel!.toInt()} %",
                              style: TextStyle(color: Colors.black))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child:
                          Divider(color: Theme.of(context).colorScheme.outline),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Batterie",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            "${widget.diesesFahrzeug.externalPower} V",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child:
                          Divider(color: Theme.of(context).colorScheme.outline),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Kilometerstand",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            "${NumberFormat.decimalPattern('de_DE').format(widget.diesesFahrzeug.mileage)} km",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child:
                          Divider(color: Theme.of(context).colorScheme.outline),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Fehlercode",
                            style: TextStyle(color: Colors.black),
                          ),
                          widget.diesesFahrzeug.faultCodes == 0 || widget.diesesFahrzeug.faultCodes == null ? Text("--",
                              style: TextStyle(color: Colors.black)) :
                          Text(
                            "${widget.diesesFahrzeug.faultCodes}",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18.0)),
              ),
              color: Colors.white,
              elevation: 0.0,
              child: SizedBox(
                width: 314,
                height: 220,
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // = size of icon on the right
                              Text(
                                "Versicherung",
                                style: Theme.of(context).textTheme.displayLarge,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Versicherungsnummer",
                            style: TextStyle(color: Colors.black),
                          ),
                          widget.diesesFahrzeug.versicherungsnummer == null || widget.diesesFahrzeug.versicherungsnummer == ""
                              ? Text(
                            "--",
                            style: TextStyle(color: Colors.black),
                          )
                              : Text(
                            "${widget.diesesFahrzeug.versicherungsnummer}",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child:
                      Divider(color: Theme.of(context).colorScheme.outline),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Versicherung",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            "${widget.diesesFahrzeug.versicherung}",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child:
                      Divider(color: Theme.of(context).colorScheme.outline),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tel. Unfall",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            "${widget.diesesFahrzeug.telefonUnfall}",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child:
                      Divider(color: Theme.of(context).colorScheme.outline),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tel. Panne",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            "${widget.diesesFahrzeug.telefonPanne}",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30.0,
            )
          ],
        ),
      ),
    );
  }
}
