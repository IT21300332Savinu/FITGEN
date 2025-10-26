import 'package:fitgen_socialbridge/screens/meal_suggestion_gate.dart';
import 'package:fitgen_socialbridge/screens/profile_screen_meal.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import 'services/firebase_config .dart';
import 'services/firebase_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

// This await call is used to initilize the social bridge function which is kept at the default, location is in backend
  await initFirebase();
/*   // Initialize default Firebase (SocialBridge)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB5GFy_H4OUQ3kEauWbvPS07Etrh4oLK9w",
      appId: "1:358273804497:web:74a6d2a9475541eec2bdf0",
      messagingSenderId: "358273804497",
      projectId: "fitgen-socialbridge-ihkwov",
      storageBucket: "fitgen-socialbridge-ihkwov.firebasestorage.app",
      authDomain: "fitgen-socialbridge-ihkwov.firebaseapp.com",
    ),
  );
*/
  // Initialize all secondary Firebase projects which are the IoT and Nutritionist functions
  await FirebaseConfig.initializeFirebase();

  // Ensure a (anonymous) user is signed in for normal/user flows so
  // profile creation/uploads won't fail with "Authentication required".
  // This uses the default Firebase app (SocialBridge) and will be
  // replaced/linked if the user later signs in with the Social Bridge flow.
  try {
    // 1) Default app (SocialBridge)
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }

    // 2) fitgen secondary app (profiles/reports)
    final fitgenAuth = FirebaseAuth.instanceFor(app: FirebaseConfig.mainApp);
    if (fitgenAuth.currentUser == null) {
      await fitgenAuth.signInAnonymously();
    }

    // 3) FitgenMedical secondary app (IoT)
    final iotAuth = FirebaseAuth.instanceFor(app: FirebaseConfig.iotApp);
    if (iotAuth.currentUser == null) {
      await iotAuth.signInAnonymously();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    print('Default uid: ${FirebaseAuth.instance.currentUser?.uid}');
    print('fitgen uid: ${fitgenAuth.currentUser?.uid}');
    print('iot uid: ${iotAuth.currentUser?.uid}');
  } catch (e) {
    // Log but don't block app startup - screen-level save operations
    // will still show error if sign-in ultimately fails.
    print('Anonymous sign-in failed at startup: $e');
  }


  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = fitgenSocialbridgeFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    authUserSub.cancel();

    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fitgen-socialbridge',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
          primary: Colors.orange,
          secondary: Colors.deepOrange,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.orange;
            }
            return Colors.white;
          }),
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({
    Key? key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'SPUHomePage';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'SPUHomePage': SPUHomePageWidget(),
      'SPUUserSportsPage': SPUUserSportsPageWidget(),
      'SPUAllMeetupPage': SPUAllMeetupPageWidget(),
      'SPUNutritionistPage': MealSuggestionGate(),
      'SPUProgressPage': SPUProgressPageWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => safeSetState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        selectedItemColor: FlutterFlowTheme.of(context).primary,
        unselectedItemColor: FlutterFlowTheme.of(context).secondaryText,
        showSelectedLabels: false,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 24.0,
            ),
            label: 'Home',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.sports_soccer,
              size: 24.0,
            ),
            label: 'Sports',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.groups_rounded,
              size: 24.0,
            ),
            label: 'Meetups',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.food_bank_sharp,
              size: 24.0,
            ),
            label: 'Nutritionist',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.line_axis,
              size: 24.0,
            ),
            label: 'Progress',
            tooltip: '',
          )
        ],
      ),
    );
  }
}
