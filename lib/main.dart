import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_localizations.dart';

import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/localization_provider.dart';
import 'pages/login_page.dart';
import 'pages/attendance_form_page.dart';
import 'pages/summary_page.dart';
import 'pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A23),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LocalizationProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => AttendanceProvider()),
    ],
    child: Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        return MaterialApp.router(
          title: 'Pegas Salary & Attendance App',
          debugShowCheckedModeBanner: false,
          locale: localizationProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: _buildSpaceTheme(),
          darkTheme: _buildSpaceDarkTheme(),
          themeMode: ThemeMode.dark,
          routerConfig: _router,

          // 📱 Add this so ALL pages stay inside a mobile-width container
          builder: (context, child) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 430, // mobile app layout width
                ),
                child: child!,
              ),
            );
          },
        );
      },
    ),
  );
}


  ThemeData _buildSpaceTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFF),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6366F1), // Cosmic indigo
        primaryContainer: Color(0xFF8B5CF6), // Deep purple
        secondary: Color(0xFF06B6D4), // Cosmic cyan
        secondaryContainer: Color(0xFF3B82F6), // Space blue
        tertiary: Color(0xFFEC4899), // Nebula pink
        tertiaryContainer: Color(0xFFF59E0B), // Solar amber
        surface: Color(0xFFFFFFFF),
        surfaceVariant: Color(0xFFF1F5F9),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1E293B),
        outline: Color(0xFFE2E8F0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.white.withOpacity(0.9),
        shadowColor: const Color(0xFF6366F1).withOpacity(0.1),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF334155),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF475569),
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  ThemeData _buildSpaceDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A23), // Deep space blue
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8B5CF6), // Cosmic purple
        primaryContainer: Color(0xFF6366F1), // Space indigo
        secondary: Color(0xFF06B6D4), // Nebula cyan
        secondaryContainer: Color(0xFF0EA5E9), // Electric blue
        tertiary: Color(0xFFEC4899), // Aurora pink
        tertiaryContainer: Color(0xFFF59E0B), // Solar gold
        surface: Color(0xFF1E1B4B), // Deep space
        surfaceVariant: Color(0xFF312E81), // Space purple
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFF1F5F9),
        outline: Color(0xFF4C1D95),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFFF1F5F9),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          color: Color(0xFFF1F5F9),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: const Color(0xFF1E1B4B).withOpacity(0.6),
        shadowColor: const Color(0xFF8B5CF6).withOpacity(0.3),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF312E81).withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: Color(0xFFCBD5E1)),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          elevation: 12,
          shadowColor: const Color(0xFF8B5CF6).withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF06B6D4),
        foregroundColor: Colors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFFF1F5F9),
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFFE2E8F0),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFCBD5E1),
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/attendance',
      builder: (context, state) => const AttendanceFormPage(),
    ),
    GoRoute(
      path: '/summary',
      builder: (context, state) => const SummaryPage(),
    ),
  ],
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // If we're on splash page, don't redirect
    if (state.fullPath == '/') {
      return null;
    }
    
    // If user is not authenticated and trying to access protected routes
    if (!authProvider.isAuthenticated && state.fullPath != '/login') {
      return '/login';
    }
    
    // If user is authenticated and on login page, redirect to attendance
    if (authProvider.isAuthenticated && state.fullPath == '/login') {
      return '/attendance';
    }
    
    return null;
  },
);