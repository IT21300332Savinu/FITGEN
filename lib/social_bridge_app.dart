// Social Bridge FlutterFlow App Wrapper
import 'package:flutter/material.dart';

import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

class SocialBridgeApp extends StatefulWidget {
  const SocialBridgeApp({super.key});

  @override
  State<SocialBridgeApp> createState() => _SocialBridgeAppState();
}

class _SocialBridgeAppState extends State<SocialBridgeApp> {
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = fitgenSocialbridgeFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });

    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FITGEN Social Bridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFFF97000),
        fontFamily: 'Outfit',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFF97000),
        fontFamily: 'Outfit',
      ),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
