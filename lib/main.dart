// ============================================================================
// MAIN ENTRY POINT - Chicken Ordering System with Firebase
// ============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/services.dart';
import 'pages/pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ChickenOrderingApp());
}

// ============================================================================
// APP ROOT WIDGET - With Provider Setup
// ============================================================================

class ChickenOrderingApp extends StatelessWidget {
  const ChickenOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Service Provider
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        // Firestore Service Provider
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
      ],
      child: MaterialApp(
        title: 'Chicken Ordering System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF16213E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.orange, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
            ),
            labelStyle: const TextStyle(color: Colors.white70),
            hintStyle: const TextStyle(color: Colors.white38),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        home: const AuthWrapper(),
        // Temporary route for Firebase testing
        routes: {
          '/test': (context) => const FirebaseTestPage(),
        },
      ),
    );
  }
}

// ============================================================================
// AUTH WRAPPER - Handles navigation based on Firebase auth state
// ============================================================================

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final authService = context.read<AuthService>();
    
    // Listen to auth state changes
    authService.authStateChanges.listen((user) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });

    // Initial check
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }
    
    // Get auth service to check current user
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;
    
    if (currentUser != null) {
      return LandingPage(userId: currentUser.uid);
    }
    
    return LoginPage(
      onRegisterTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterPage(
              onLoginTap: () => Navigator.pop(context),
              onRegisterSuccess: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      onLoginSuccess: () {
        // Navigation handled by auth state listener
      },
    );
  }
}

