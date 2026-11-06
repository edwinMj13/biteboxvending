// ADMIN PORTAL entry point.
//
// Run:    flutter run -d chrome -t lib/main_admin.dart
// Build:  flutter build web -t lib/main_admin.dart -o build/admin
//
// The public website uses lib/main.dart. Both apps share the same Firebase
// project and the data layer in lib/core/content/.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'admin/admin_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: AdminApp()));
}
