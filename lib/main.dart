import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:glow_and_go/pages/auth/auth_page.dart';
import 'package:glow_and_go/provider/app_state_provider.dart';
import 'package:glow_and_go/provider/auth_provider.dart';
import 'package:glow_and_go/provider/salon_provider.dart';
import 'package:glow_and_go/service/network_service.dart';
import 'package:glow_and_go/session_manager/user_session.dart';

import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Initialize Firebase ---
  await Firebase.initializeApp();

  // --- Firestore offline persistence ---
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // --- Load user session safely ---
  try {
    await UserSession.loadUser();
  } catch (e) {
    debugPrint('User session load error: $e');
  }

  // --- Global error handlers ---
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error');
    return true;
  };

  // --- Run app with providers ---
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SalonProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Start network listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NetworkChecker.initialize(context);
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salon App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const AuthPage(),
    );
  }
}
