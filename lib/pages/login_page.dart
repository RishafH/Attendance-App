import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/liquid_glass_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SpaceGradientBackground(
        isDark: isDark,
        hasStars: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ultra-attractive logo with liquid glass effect
                  LiquidGlassContainer(
                    width: 120,
                    height: 120,
                    gradientColors: [
                      const Color(0xFF0EA5E9).withOpacity(0.3),
                      const Color(0xFF06B6D4).withOpacity(0.2),
                    ],
                    child: const Icon(
                      Icons.location_on,
                      size: 60,
                      color: Color(0xFF06B6D4),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Welcome message with liquid glass design
                  LiquidGlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      children: [
                        Text(
                          'Welcome to',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white.withOpacity(0.8) : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pegas Attendance',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF06B6D4) : const Color(0xFF0EA5E9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login form with liquid glass design
                  LiquidGlassContainer(
                    padding: const EdgeInsets.all(24.0),
                    gradientColors: [
                      theme.colorScheme.surface.withOpacity(0.7),
                      theme.colorScheme.surface.withOpacity(0.3),
                    ],
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Username field
                          FormBuilderTextField(
                            name: 'username',
                            initialValue: 'demo',
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface.withOpacity(0.5),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ]),
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          FormBuilderTextField(
                            name: 'password',
                            initialValue: 'demo',
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface.withOpacity(0.5),
                            ),
                            obscureText: true,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ]),
                          ),

                          const SizedBox(height: 24),

                          // Login button with liquid glass effect
                          SizedBox(
                            width: double.infinity,
                            child: LiquidGlassButton(
                              text: 'Login',
                              onPressed: _isLoading ? () {} : _handleLogin,
                              isLoading: _isLoading,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Skip login button
                          TextButton(
                            onPressed: () => context.go('/attendance'),
                            child: Text(
                              'Skip Login (Demo Mode)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? const Color(0xFF06B6D4) : const Color(0xFF0EA5E9),
                              ),
                            ),
                          ),

                          // Error message display
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              if (authProvider.errorMessage != null) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authProvider.errorMessage!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Demo credentials info with liquid glass style
                  LiquidGlassContainer(
                    padding: const EdgeInsets.all(20.0),
                    gradientColors: [
                      const Color(0xFF06B6D4).withOpacity(0.1),
                      const Color(0xFF06B6D4).withOpacity(0.05),
                    ],
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info, 
                              color: isDark ? const Color(0xFF06B6D4) : const Color(0xFF0EA5E9),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Demo Credentials',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF06B6D4) : const Color(0xFF0EA5E9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Username: demo\nPassword: demo',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark 
                                ? Colors.white.withOpacity(0.8) 
                                : const Color(0xFF475569),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final formData = _formKey.currentState!.value;
      
      final success = await authProvider.login(
        formData['username'],
        formData['password'],
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          context.go('/attendance');
        }
      }
    }
  }
}