// Experiment 8: Searching Information in Google Firestore Database
// Library Book Search System
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'book_search_page.dart';
import 'firebase_options.dart';
import 'firebase_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? initError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    initError = e;
  }
  runApp(MyApp(initError: initError));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initError});

  final Object? initError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library Book Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: initError == null
          ? const BookSearchPage()
          : FirebaseSetupScreen(title: 'Library Book Search', error: initError!),
    );
  }
}
