import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pfx_fuhrpark/src/features/home/objects/fahrzeug.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../data/fahrzeugschein_provider.dart';

class EditFahrzeugScreen extends ConsumerStatefulWidget {
  final Fahrzeug diesesFahrzeug;
  const EditFahrzeugScreen({super.key, required this.diesesFahrzeug});

  @override
  ConsumerState<EditFahrzeugScreen> createState() => _EditFahrzeugScreenState();
}

class _EditFahrzeugScreenState extends ConsumerState<EditFahrzeugScreen> {
  Uint8List? _scheinData;
  String? _contentType;


  @override
  void initState() {
    super.initState();
  }

  Future<void> _openPdf(Uint8List data) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/fahrzeugschein.pdf';

      final file = File(filePath);
      await file.writeAsBytes(data);

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        print("PDF konnte nicht geöffnet werden: ${result.message}");
      }
    } catch (e) {
      print("Fehler beim Öffnen der PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheinAsync =
        ref.watch(fahrzeugscheinProvider(widget.diesesFahrzeug.name ?? ''));

    final codes = widget.diesesFahrzeug.faultCode ?? [];
    final reportedCount = widget.diesesFahrzeug.faultCodes ?? 0;
    final hintNeeded = reportedCount > codes.length;
    final showWeiterenHinweis = codes.isNotEmpty && hintNeeded;
    final showGrundHinweis = codes.isEmpty && hintNeeded;

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
                    color: Colors.white,
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
                    SizedBox(
                      height: 40.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),

                              /// Condition for which image shall be displayed
                              child: buildVehicleImage(),
                            ),
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
            const SizedBox(height: 20.0),
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
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            (reportedCount > 0 || codes.isNotEmpty)
                ?
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18.0)),
          ),
          color: Colors.white,
          elevation: 0.0,
          child: SizedBox(
            width: 314,
            height: 150,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Fehlercodes",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (codes.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: codes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            codes[index],
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (reportedCount > codes.length)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      codes.isEmpty
                          ? "OBD Stecker Firmware veraltet. \n Bitte prüfe die Anzeige im Fahrzeug für Details."
                          : "Weitere Fehlercodes könnten direkt im Fahrzeug angezeigt werden.",
                      style: const TextStyle(color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ) : const SizedBox.shrink(),
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
                          widget.diesesFahrzeug.versicherungsnummer == null ||
                                  widget.diesesFahrzeug.versicherungsnummer ==
                                      ""
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
                height: 300,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // = size of icon on the right
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            "Fahrzeugschein",
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        )
                      ],
                    ),
                    scheinAsync.when(
                      loading: () => Expanded(
                          child:
                              const Center(child: CircularProgressIndicator())),
                      error: (err, _) =>
                          Expanded(child: Center(child: Text("Fehler: $err"))),
                      data: (schein) {
                        if (schein.data == null) {
                          return Expanded(
                              child: const Center(
                                  child:
                                      Text("Kein Fahrzeugschein verfügbar")));
                        }

                        if (schein.contentType?.contains('image') ?? false) {
                          return Column(
                            children: [
                              const SizedBox(height: 10),
                              // Text("Fahrzeugschein", style: Theme.of(context).textTheme.displayLarge),
                              const SizedBox(height: 10),
                              Image.memory(schein.data!,
                                  height: 220, fit: BoxFit.contain),
                            ],
                          );
                        } else if (schein.contentType?.contains('pdf') ??
                            false) {
                          return Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _openPdf(schein.data!);
                                  },
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text("PDF öffnen"),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const Center(
                              child: Text("Unbekanntes Format"));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  // Widget buildFaultCodes(Fahrzeug fzg){
  //   Widget result;
  //   int anzahlCodes = fzg.faultCode!.length + 1;
  //   for(int i, i < anzahlCodes, i++){
  //
  //   }
  //   return result;
  // }

  bool isOlderThan2Days(String timeString) {
    final format = DateFormat('dd.MM.yy HH:mm:ss');
    try {
      final dateTime = format.parse(timeString);
      return DateTime.now().difference(dateTime).inDays > 2;
    } catch (e) {
      return false;
    }
  }

  Widget buildVehicleImage() {
    final fahrzeug = widget.diesesFahrzeug;
    final isOld = isOlderThan2Days(fahrzeug.gpsTimeString ?? '');

    Image image;

    if (fahrzeug.typNummer == "3") {
      image = Image.asset(
        'assets/images/lkw.png',
        width: 130,
        height: 90,
        fit: BoxFit.cover,
      );
    } else if (fahrzeug.typNummer == "2" ||
        fahrzeug.typNummer == "1" ||
        fahrzeug.typNummer == "4" ||
        fahrzeug.typNummer == null) {
      image = Image.asset(
        'assets/images/pkw.png',
        width: 130,
        height: 90,
        fit: BoxFit.cover,
      );
    } else {
      image = Image.asset(
        'assets/images/anhaenger.png',
        width: 130,
        height: 90,
        fit: BoxFit.cover,
      );
    }

    final decoratedImage = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(100.0)),
      child: isOld
          ? ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: image,
      )
          : image,
    );

    return decoratedImage;
  }
}
