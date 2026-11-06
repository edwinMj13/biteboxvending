import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/content/content_providers.dart';
import 'admin_theme.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_login_screen.dart';

final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

/// Whether the signed-in user has an `admins/{uid}` document.
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return false;
  return ref.read(contentRepositoryProvider).isAdmin(user.uid);
});

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiteBox Admin',
      debugShowCheckedModeBanner: false,
      theme: buildAdminTheme(),
      home: const _AuthGate(),
    );
  }
}

/// Signed out → login. Signed in but not admin → access denied.
/// Signed in as admin → dashboard.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final user = auth.valueOrNull;

    if (auth.isLoading) return const _Loading();
    if (user == null) return const AdminLoginScreen();

    return ref.watch(isAdminProvider).when(
          loading: () => const _Loading(),
          error: (e, _) => _AccessDenied(user: user, error: e.toString()),
          data: (isAdmin) =>
              isAdmin ? const AdminDashboardScreen() : _AccessDenied(user: user),
        );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _AccessDenied extends StatelessWidget {
  final User user;
  final String? error;
  const _AccessDenied({required this.user, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AdminColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Not an admin',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'OTP verified, but this Firebase account has no admin access '
                'yet (one-time setup).\n\n'
                'In the Firebase console, open Firestore and create a document '
                'at admins/<UID> (any fields) using this UID:',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 12),
              SelectableText(
                user.uid,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
