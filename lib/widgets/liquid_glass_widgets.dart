import 'dart:ui';
import 'package:flutter/material.dart';

/// Ultra-attractive liquid glass widget with space-level effects
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final List<Color>? gradientColors;
  final double blur;
  final double opacity;
  final bool hasGlow;
  final Color? glowColor;
  final bool isAnimated;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradientColors,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.hasGlow = false,
    this.glowColor,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultGradient = isDark
        ? [
            const Color(0xFF1E1B4B).withOpacity(0.3),
            const Color(0xFF312E81).withOpacity(0.2),
            const Color(0xFF4C1D95).withOpacity(0.1),
          ]
        : [
            Colors.white.withOpacity(0.7),
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ];

    Widget glassMorphism = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ?? defaultGradient,
        ),
        border: Border.all(
          color: isDark
              ? const Color(0xFF6366F1).withOpacity(0.3)
              : Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF8B5CF6).withOpacity(0.2)
                : const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (hasGlow)
            BoxShadow(
              color: glowColor?.withOpacity(0.4) ??
                  const Color(0xFF8B5CF6).withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(isDark ? 0.05 : 0.1),
                  Colors.white.withOpacity(isDark ? 0.02 : 0.05),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (isAnimated) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: Opacity(
              opacity: value,
              child: glassMorphism,
            ),
          );
        },
      );
    }

    return glassMorphism;
  }
}

/// Space-themed gradient background
class SpaceGradientBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final bool hasStars;

  const SpaceGradientBackground({
    super.key,
    required this.child,
    this.isDark = true,
    this.hasStars = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0A23), // Deep space
                  Color(0xFF1E1B4B), // Space purple
                  Color(0xFF312E81), // Nebula blue
                  Color(0xFF4C1D95), // Cosmic indigo
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFF), // Light cosmic white
                  Color(0xFFEEF2FF), // Soft indigo
                  Color(0xFFE0E7FF), // Light purple
                  Color(0xFFDDD6FE), // Ethereal lavender
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
      ),
      child: hasStars
          ? Stack(
              children: [
                // Animated floating particles/stars
                ...List.generate(
                  20,
                  (index) => Positioned(
                    left: (index * 37.0) % MediaQuery.of(context).size.width,
                    top: (index * 53.0) % MediaQuery.of(context).size.height,
                    child: AnimatedFloatingParticle(
                      delay: Duration(milliseconds: index * 200),
                      isDark: isDark,
                    ),
                  ),
                ),
                child,
              ],
            )
          : child,
    );
  }
}

/// Animated floating particles for space effect
class AnimatedFloatingParticle extends StatefulWidget {
  final Duration delay;
  final bool isDark;

  const AnimatedFloatingParticle({
    super.key,
    required this.delay,
    this.isDark = true,
  });

  @override
  State<AnimatedFloatingParticle> createState() =>
      _AnimatedFloatingParticleState();
}

class _AnimatedFloatingParticleState extends State<AnimatedFloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 3000 + (widget.delay.inMilliseconds % 1000)),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value * 20 - 10),
          child: Opacity(
            opacity: 0.3 + (_animation.value * 0.4),
            child: Container(
              width: 3 + (_animation.value * 2),
              height: 3 + (_animation.value * 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDark
                    ? const Color(0xFF8B5CF6).withOpacity(0.6)
                    : const Color(0xFF6366F1).withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark
                        ? const Color(0xFF8B5CF6).withOpacity(0.3)
                        : const Color(0xFF6366F1).withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Space-themed button with liquid glass effect
class LiquidGlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? color;
  final double? width;
  final bool hasGlow;

  const LiquidGlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color,
    this.width,
    this.hasGlow = true,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.hasGlow) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = widget.color ??
        (isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1));

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  buttonColor,
                  buttonColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withOpacity(_glowAnimation.value * 0.5),
                  blurRadius: 20,
                  spreadRadius: _isPressed ? 2 : 5,
                  offset: const Offset(0, 4),
                ),
                if (widget.hasGlow)
                  BoxShadow(
                    color: buttonColor.withOpacity(_glowAnimation.value * 0.3),
                    blurRadius: 40,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.95 : 1.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: ElevatedButton.icon(
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : widget.icon != null
                          ? Icon(widget.icon, color: Colors.white)
                          : const SizedBox.shrink(),
                  label: Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}