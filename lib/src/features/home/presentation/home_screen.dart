import 'dart:io';
import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../authentication/data/auth_repository.dart';
import '../data/fahrzeug_provider.dart';
import '../objects/fahrzeug.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _vibration = false;
  bool _ledLicht = false;
  MenuItem selectedItem = items[0];
  MenuItem selectedFarbItem = lichtfarben[0];
  bool istPrivatfahrt = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await ref.read(userProvider.future);
      setState(() {
        istPrivatfahrt = user.privatfahrt;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   centerTitle: true,
      //   title: Switch(value: istPrivatfahrt, onChanged: (bool value) {
      //     // This is called when the user toggles the switch.
      //     setState(() {
      //       istPrivatfahrt = value;
      //     });
      //   },),
      // ),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      // backgroundColor: Colors.grey,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Transform.translate(
        offset: Offset(16, 0),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors
                      .transparent, // wichtig, damit Schatten sichtbar bleibt
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade900.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, -10), // Schatten NACH OBEN
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: InvertedRoundedRectanglePainterLeft(
                    color: Colors.white,
                    radius: 15.0,
                  ),
                  child: const SizedBox(height: 15.0, width: 30.0),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors
                      .transparent, // wichtig, damit Schatten sichtbar bleibt
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade900.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, -10), // Schatten NACH OBEN
                    ),
                  ],
                ),
                child: Container(
                  decoration: ShapeDecoration(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(18.0),
                        topLeft: Radius.circular(18.0),
                      ),
                    ),
                    color: Colors.white,
                  ),
                  width: 140.0,
                  height: 80.0,
                  child: Column(
                    children: [
                      Switch(
                          value: istPrivatfahrt,
                          onChanged: (bool value) async{
                              setState(() => istPrivatfahrt = value);

                              final user = await ref.read(userProvider.future);
                              final repo = ref.read(privatfahrtRepositoryProvider);
                              final success = await repo.updatePrivatfahrt(personalnummer: user.personalnummer, status: value);

                              if (!success) {
                                setState(() => istPrivatfahrt = !value); // Rückgängig
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Privatfahrt konnte nicht aktualisiert werden')),
                                  );
                                }
                              }
                          }),
                      Text(
                        "Privatfahrt",
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (user) {
          final fahrzeugeAsync =
              ref.watch(fahrzeugeProvider(user.personalnummer.toString()));

          return fahrzeugeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (fahrzeuge) {
              if (fahrzeuge.length == 1) {
                final fzg = fahrzeuge.first;
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Dein kompletter Card-Stack hier wie im ListView.builder (kopiert oder ausgelagert)
                            buildFahrzeugCard(context, fzg),
                          ],
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: fahrzeuge.length + 1,
                  itemBuilder: (context, index) {
                    if (index == fahrzeuge.length) return const SizedBox(height: 50);
                    final fzg = fahrzeuge[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildFahrzeugCard(context, fzg),
                      ],
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  /// __________HILFSMETHODEN_____________________________________________________________


  Widget buildFahrzeugCard(BuildContext context, Fahrzeug fzg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            (fzg.ignition == true &&
                fzg.gpsTimeString != null &&
                fzg.gpsTimeString!.isNotEmpty &&
                !isOlderThan2Days(fzg.gpsTimeString!))
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40.0,
                ),
                Row(
                  children: [
                    Container(
                      height: 270.0,
                      width: 300.0,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 30,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 7.0,
                    )
                  ],
                ),
              ],
            )
                : SizedBox(
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 35.0),
              child: GestureDetector(
                  onTap: () {
                    context
                        .push('/home/editFahrzeug', extra: fzg)
                        .then((value) => setState(() {}));
                  },
                  child: fzg.typNummer == "2" ||
                      fzg.typNummer == "1" ||
                      fzg.typNummer == "4" ||
                      fzg.typNummer == null
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18.0),
                    ),
                    child: isOlderThan2Days(fzg.gpsTimeString!)
                        ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                      child: Image.asset(
                        'assets/images/pkw.png',
                        width: 314,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Image.asset(
                      'assets/images/pkw.png',
                      width: 314,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                      : fzg.typNummer == "3"
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18.0),
                    ),
                    child: isOlderThan2Days(fzg.gpsTimeString!)
                        ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                      child: Image.asset(
                        'assets/images/lkw.png',
                        width: 314,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Image.asset(
                      'assets/images/lkw.png',
                      width: 314,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                      : ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18.0),
                    ),
                    child: isOlderThan2Days(fzg.gpsTimeString!)
                        ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                      child: Image.asset(
                        'assets/images/anhaenger.png',
                        width: 314,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Image.asset(
                      'assets/images/anhaenger.png',
                      width: 314,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 160),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18.0)),
                      ),
                      margin: EdgeInsets.zero,
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16.0, 8.0, 15.0, 6.0),
                        child: Text(
                          fzg.name ?? "Unbekanntes Fahrzeug",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: InvertedRoundedRectanglePainter(
                        color: Colors.white,
                        radius: 15.0,
                      ),
                      child: const SizedBox(
                          height: 15.0, width: 50.0),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(18.0),
                          bottomLeft: Radius.circular(18.0),
                          bottomRight: Radius.circular(18.0),
                        ),
                      ),
                      margin: EdgeInsets.zero,
                      elevation: 0.0,
                      child: SizedBox(
                        height: 112.0,
                        width: 314,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 8.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 3.0),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: (fzg.gpsTimeString != null && isOlderThan2Days(fzg.gpsTimeString!))
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.onSecondary,
                                    size: 23.0,
                                  ),
                                  const SizedBox(width: 4.0),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      fzg.gpsTimeString ?? "Zeit unbekannt",
                                      style: (fzg.gpsTimeString != null && isOlderThan2Days(fzg.gpsTimeString!))
                                          ? Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(color: Colors.red)
                                          : Theme.of(context).textTheme.displaySmall,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Icon(Icons.local_gas_station,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      size: 23.0),
                                  const SizedBox(width: 4.0),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                        fzg.fuelLevel == null ||
                                            fzg.fuelLevel
                                                .toString() ==
                                                "null"
                                            ? "-"
                                            : fzg.fuelLevel!
                                            .toInt()
                                            .toString() +
                                            " %",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall),
                                  ),
                                  const SizedBox(width: 9.0),
                                  RotatedBox(
                                    quarterTurns: 1,
                                    child: Icon(
                                      Icons.battery_full,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      size: 23.0,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      "${fzg.externalPower?.toStringAsFixed(1) ?? '-'} V",
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2.0),
                              Divider(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline),
                              const SizedBox(height: 6.0),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 37.0,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        context.push(
                                            '/home/editFahrzeug',
                                            extra: fzg);
                                      },
                                      child: Text("Details",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge),
                                    ),
                                  ),
                                  const SizedBox(width: 7.0),
                                  SizedBox(
                                    height: 37.0,
                                    child: FilledButton(
                                      onPressed: () {
                                        context.push('/map',
                                            extra:
                                            fzg); // Fahrzeug-Objekt übergeben
                                      },
                                      style: ButtonStyle(
                                        padding:
                                        MaterialStateProperty
                                            .all(const EdgeInsets
                                            .symmetric(
                                            horizontal:
                                            14.0)),
                                      ),
                                      child: Text("   Karte   ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 35.0),
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(18.0),
                    bottomLeft: Radius.circular(18.0),
                  ),
                ),
                margin: EdgeInsets.zero,
                elevation: 0.0,
                child:
                fzg.faultCodes == 0 || fzg.faultCodes == null
                    ? SizedBox(
                  height: 0.0,
                )
                    : Container(
                  height: 36.0,
                  width: 36.0,
                  // color: Colors.red,
                  child: Center(
                      child: Text(
                        '${fzg.faultCodes}',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ),
            ),
            if (fzg.ignition == true &&
                (fzg.gpsTimeString?.isNotEmpty ?? false) &&
                !isOlderThan2Days(fzg.gpsTimeString!))
              Padding(
                padding: const EdgeInsets.only(right: 200.0, top: 45.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(50),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(76),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Text(
                    "in Bewegung",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }


  bool isOlderThan2Days(String timeString) {
    final format = DateFormat('dd.MM.yy HH:mm:ss');
    try {
      final dateTime = format.parse(timeString);
      return DateTime.now().difference(dateTime).inDays > 2;
    } catch (e) {
      return false;
    }
  }

}

class InvertedRoundedRectanglePainter extends CustomPainter {
  InvertedRoundedRectanglePainter({
    required this.radius,
    required this.color,
  });

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cornerSize = Size.square(radius * 2);
    canvas.drawPath(
      Path()
        ..addArc(
          // top-left arc
          Offset(0, -radius) & cornerSize,
          // 180 degree startAngle (left of circle)
          pi,
          // -90 degree sweepAngle (counter-clockwise to the bottom)
          -pi / 2,
        )
        //   ..arcTo(
        //     // top-right arc
        //     Offset(size.width - cornerSize.width, -radius) & cornerSize,
        //     // 90 degree startAngle (bottom of circle)
        //     pi / 2,
        //     // -90 degree sweepAngle (counter-clockwise to the right)
        //     -pi / 2,
        //     false,
        //   )
        // // bottom right of painter
        //   ..lineTo(size.width, size.height)
        // bottom left of painter
        ..lineTo(0, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(InvertedRoundedRectanglePainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}

class InvertedRoundedRectanglePainterLeft extends CustomPainter {
  InvertedRoundedRectanglePainterLeft({
    required this.radius,
    required this.color,
  });

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cornerSize = Size.square(radius * 2);
    canvas.drawPath(
      Path()
        ..addArc(
          // top-left arc
          Offset(0, -radius) & cornerSize,
          // 180 degree startAngle (left of circle)
          0,
          // -90 degree sweepAngle (counter-clockwise to the bottom)
          pi / 2,
        )
        // bottom left of painter
        ..lineTo(cornerSize.width, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(InvertedRoundedRectanglePainterLeft oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}

const List<MenuItem> lichtfarben = [rot, gruen, blau];
const rot = MenuItem(
    title: 'Rot', icon: Icons.circle, color: Colors.red, description: '');
const gruen = MenuItem(
    title: 'Grün', icon: Icons.circle, color: Colors.green, description: '');
const blau = MenuItem(
    title: 'Blau', icon: Icons.circle, color: Colors.blue, description: '');

/// _________________________________________________________________________________________///
///
const List<MenuItem> items = [Privatfahrt, Firmenfahrt];

const Privatfahrt = MenuItem(
    title: 'Privatfahrt',
    icon: Icons.person,
    color: Colors.white,
    description: '');
const Firmenfahrt = MenuItem(
    title: 'Firmenfahrt',
    icon: Icons.business_outlined,
    color: Colors.white,
    description: '');

List<double> _getCustomItemsHeights() {
  // final List<double> itemsHeights = [];
  // for (int i = 0; i < items.length; i++) {
  //   // der letzte Eintrag hat keinen divider angefügt bekommen (in der buildItemDescription Methode), daher geringere height
  //   if (i == items.length - 1) {
  //     itemsHeights.add(75);
  //   }
  //   //falls ein Eintrag von den anderen abweicht, hier mit else if individualisieren
  //   else if (i == 1){
  //     itemsHeights.add(95);
  //   }
  //   else {
  //     itemsHeights.add(78);
  //   }
  // }
  // return itemsHeights;
  return [50, 50];
}

List<double> _getCustomFarbItemsHeights() {
  return [40, 40];
}

class MenuItem {
  const MenuItem({
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
  });

  final String title;
  final IconData icon;
  final String description;
  final Color color;

  @override
  String toString() {
    return this.title;
  }

  static Widget buildItemTitleUniqueColor(MenuItem item, BuildContext context) {
    return Row(
      children: [
        Icon(item.icon, color: item.color, size: 22),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  static Widget buildItemDescriptionUniqueColor(
      MenuItem item, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(item.icon, color: item.color, size: 22),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ],
        ),
        // Padding(
        //   padding: const EdgeInsets.all(5.0),
        //   child: Row(
        //     children: [
        //       Expanded(
        //           child: Text(
        //         item.description,
        //         style: context.textTheme.displaySmall,
        //       ))
        //     ],
        //   ),
        // ),
        if (item != lichtfarben.last)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 2.0),
          ),
      ],
    );
  }

  static Widget buildItemTitle(MenuItem item, BuildContext context) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  static Widget buildItemDescription(MenuItem item, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(item.icon,
                color: Theme.of(context).colorScheme.onSecondary, size: 22),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ],
        ),
        // Padding(
        //   padding: const EdgeInsets.all(5.0),
        //   child: Row(
        //     children: [
        //       Expanded(
        //           child: Text(
        //             item.description,
        //             style: Theme
        //                 .of(context)
        //                 .textTheme
        //                 .displaySmall,
        //           ))
        //     ],
        //   ),
        // ),
        // if (item != items.last) const Divider(height: 8.0),
      ],
    );
  }
}

