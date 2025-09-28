import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/liquid_glass_widgets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check auth status
    await authProvider.checkAuthStatus();
    
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      if (authProvider.isAuthenticated) {
        context.go('/attendance');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SpaceGradientBackground(
        isDark: isDark,
        hasStars: true,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ultra-attractive app logo with liquid glass effect
                LiquidGlassContainer(
                  width: 150,
                  height: 150,
                  hasGlow: true,
                  glowColor: const Color(0xFF8B5CF6),
                  isAnimated: true,
                  borderRadius: BorderRadius.circular(32),
                  child: const Icon(
                    Icons.business_center,
                    size: 80,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // App title with liquid glass background
                LiquidGlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  hasGlow: true,
                  isAnimated: true,
                  child: Column(
                    children: [
                      Text(
                        'PEGAS',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        l10n.appTitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          letterSpacing: 1.2,
                          color: isDark 
                              ? Colors.white.withOpacity(0.8)
                              : const Color(0xFF475569),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Animated loading indicator with space theme
                LiquidGlassContainer(
                  width: 80,
                  height: 80,
                  hasGlow: true,
                  glowColor: const Color(0xFF06B6D4),
                  child: const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Loading text with space theme
                Text(
                  '${l10n.loading}...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    letterSpacing: 1.5,
                    color: isDark 
                        ? Colors.white.withOpacity(0.6)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}