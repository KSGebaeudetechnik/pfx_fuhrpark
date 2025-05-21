import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pfx_fuhrpark/src/features/network_sync/sync_service.dart';
// import 'package:flutter_start_project/src/common_widgets/no_page_transition.dart';
import 'package:pfx_fuhrpark/src/routing/app_router.dart';
import 'package:pfx_fuhrpark/src/utils/custom_color_swatch.dart';
import 'package:pfx_fuhrpark/src/utils/dismiss_keyboard.dart';
import 'package:pfx_fuhrpark/src/utils/objectbox.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:flutter_localizations/flutter_localizations.dart';

late ObjectBox objectBox;
late SyncService syncService;
final GlobalKey<_MyAppState> myAppKey = GlobalKey<_MyAppState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.create();

  runApp(const ProviderScope(child: MyApp()));
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}
// This widget is the root of your application.

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(goRouterProvider);
    return DismissKeyboard(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: goRouter,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('de'),
        ],
        title: 'Flutter Starter Project',
        theme: ThemeData(
          ///Farbschema Möglichkeit 1
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(
          //
          // ),

          ///Farbschema Möglichkeit 2
          ///Kommentare entsprechen den Farb-Variablen in Figma
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: createMaterialColor(Color(0xFF244F8F)))
              .copyWith(
            error: Colors.red[400],
            background: const Color(0xFFE1E8F5), //Log In Background
            onBackground: const Color(0xFF668ACC), //PW field text
            primaryContainer: const Color(0xFF244F8F), //Card Buttons
            onSecondary: const Color(0xFF2F4162), //Nav Bar Text
            outline: const Color(0xFFAEBACC), //Divider
            secondaryContainer: const Color(0xFFECF0F8), //Background
            secondary: const Color(0xFFCADCF7), //Nav selected
            tertiary: const Color(0xFF85AAE0), //Diagram color

            //#46a5f4 , 0xFFE6685C
          ),

          ///Hintergrundfarbe der App
          scaffoldBackgroundColor: Colors.white,

          ///Farbe der Appbar/Header
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            //elevation: 2,
          ),

          navigationBarTheme: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 13.0,
                  color: Color(0xFF2F4162), //Nav Bar Text
                ),
              ),
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFCADCF7), //Nav selected
              iconTheme: MaterialStateProperty.all(const IconThemeData(
                color: Color(0xFF2F4162),
              ))),

          // pageTransitionsTheme: const PageTransitionsTheme(
          //   builders: {
          //     TargetPlatform.android: NoTransitionsBuilder(),
          //     TargetPlatform.iOS: NoTransitionsBuilder(),
          //   },
          // ),

          ///Text Theme
          textTheme: const TextTheme(
            titleSmall: TextStyle(
                fontFamily: "Roboto",
                fontSize: 17.0,
                fontWeight: FontWeight.w500,
                color: Colors.black
            ),
            labelLarge: TextStyle(
              fontFamily: "Roboto",
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF244F8F), //Card Buttons
            ),
            titleMedium: TextStyle(
                fontFamily: "Roboto",
                fontSize: 24.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: Colors.black //Nav Bar Text
            ),
            headlineSmall: TextStyle(
                fontFamily: "Roboto",
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F4162) //Nav Bar Text
            ),
            labelSmall: TextStyle(
              fontFamily: "Roboto",
              fontSize: 13.0,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(
              fontFamily: "Roboto",
              fontSize: 14.0,
              color: Color(0xFF244F8F), //Card Buttons
            ),
            bodyMedium: TextStyle(
              fontFamily: "Roboto",
              fontSize: 15.0,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
            bodySmall: TextStyle(
              fontFamily: "Roboto",
              fontSize: 12.0,
              color: Color(0xFF244F8F), //Card Buttons
            ),
            displayLarge: TextStyle(
              fontFamily: "Roboto",
              fontSize: 16.0,

              color: Color(0xFF2F4162), //Nav Bar Text
            ),
            displayMedium: TextStyle(
              fontFamily: "Roboto",
              fontSize: 14.0,
              color: Color(0xFF244F8F), //Card Buttons
            ),
            displaySmall: TextStyle(
                fontFamily: "Roboto",
                fontSize: 13.0,
                color: Color(0xFF2F4162) //Nav Bar Text
            ),
            headlineMedium: TextStyle(
                fontFamily: "Roboto",
                fontSize: 20.0,
                color: Color(0xFF2F4162) //Nav Bar Text
            ),
            headlineLarge: TextStyle(
              fontFamily: "Roboto",
              fontSize: 24.0,
              color: Color(0xFF2F4162), //Nav Bar Text
            ),
            titleLarge: TextStyle(
                fontFamily: "Roboto",
                fontSize: 18.0,
                color: Color(0xFF2F4162) //Nav Bar Text
            ),
            labelMedium: TextStyle(
              fontFamily: "Roboto",
              fontWeight: FontWeight.w300,
              color: Colors.grey,
              fontSize: 12.0,
            ),
          ).apply(
            // bodyColor: const Color(0xFF1E2F45),
            // displayColor: const Color(0xFF1E2F45),
          ),

          useMaterial3: true,
        ),
      ),
    );
  }
}
