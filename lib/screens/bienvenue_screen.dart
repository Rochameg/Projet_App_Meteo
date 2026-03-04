import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meteo_provider.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _orbitCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _floatAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _floatAnim = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _orbitCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeteoFournisseur>();
    final isDark = provider.estModeSombre;
    final primary = isDark ? AppTheme.primaryCyan : AppTheme.primaryBlue;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080C14) : const Color(0xFFF0F4FF),
      body: Stack(
        children: [
          
          _BackgroundOrbs(isDark: isDark, primary: primary, orbitCtrl: _orbitCtrl),

          
          CustomPaint(
            size: size,
            painter: _GridPainter(
              color: primary.withOpacity(isDark ? 0.04 : 0.06),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _entryAnim,
              child: Column(
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.6),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'MÉTÉO APP',
                              style: TextStyle(
                                color: primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 5,
                              ),
                            ),
                          ],
                        ),
                        _ThemeToggle(
                          isDark: isDark,
                          primary: primary,
                          onTap: provider.basculerTheme,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  
                  AnimatedBuilder(
                    animation: Listenable.merge([_floatAnim, _pulseAnim]),
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: Transform.scale(
                          scale: _pulseAnim.value,
                          child: _GlobeWidget(
                            isDark: isDark,
                            primary: primary,
                            orbitCtrl: _orbitCtrl,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _entryCtrl,
                      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                    )),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: isDark
                                ? [AppTheme.primaryCyan, const Color(0xFF7B61FF)]
                                : [AppTheme.primaryBlue, const Color(0xFF0066FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'MÉTÉO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 58,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 14,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'EN TEMPS RÉEL',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                            fontSize: 12,
                            letterSpacing: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Données météo en direct pour\n5 métropoles mondiales',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.45)
                            : Colors.black.withOpacity(0.45),
                        fontSize: 14,
                        height: 1.9,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _CityChip(label: 'Paris', image: 'assets/images/paris.jpg', isDark: isDark, primary: primary),
                        _CityChip(label: 'Tokyo', image: 'assets/images/tokyo.jpg', isDark: isDark, primary: primary),
                        _CityChip(label: 'New York', image: 'assets/images/new_york.jpg', isDark: isDark, primary: primary),
                        _CityChip(label: 'Sydney', image: 'assets/images/sydney.jpg', isDark: isDark, primary: primary),
                        _CityChip(label: 'Dubai', image: 'assets/images/dubai.jpg', isDark: isDark, primary: primary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _LaunchButton(isDark: isDark, primary: primary),
                  ),

                  const SizedBox(height: 52),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _BackgroundOrbs extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final AnimationController orbitCtrl;

  const _BackgroundOrbs({
    required this.isDark,
    required this.primary,
    required this.orbitCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: orbitCtrl,
      builder: (_, __) {
        final t = orbitCtrl.value * 2 * math.pi;
        return Stack(
          children: [
            Positioned(
              top: -80 + math.sin(t) * 30,
              right: -80 + math.cos(t * 0.5) * 20,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(isDark ? 0.18 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100 + math.cos(t) * 25,
              left: -60 + math.sin(t * 0.7) * 20,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isDark ? const Color(0xFF7B61FF) : const Color(0xFF0044FF))
                          .withOpacity(isDark ? 0.12 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;

    const spacing = 32.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}


class _GlobeWidget extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final AnimationController orbitCtrl;

  const _GlobeWidget({
    required this.isDark,
    required this.primary,
    required this.orbitCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.25),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),

          
          AnimatedBuilder(
            animation: orbitCtrl,
            builder: (_, __) => Transform.rotate(
              angle: orbitCtrl.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(170, 170),
                painter: _OrbitRingPainter(color: primary.withOpacity(0.4)),
              ),
            ),
          ),

          
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primary.withOpacity(0.25),
                  primary.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: primary.withOpacity(0.5),
                width: 1.5,
              ),
            ),
          ),

          
          const Text('🌍', style: TextStyle(fontSize: 72)),

          
          Positioned(
            top: 28,
            right: 28,
            child: _PingDot(color: primary),
          ),
        ],
      ),
    );
  }
}

class _PingDot extends StatefulWidget {
  final Color color;
  const _PingDot({required this.color});
  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 20 * _ctrl.value + 8,
            height: 20 * _ctrl.value + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity((1 - _ctrl.value) * 0.4),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [BoxShadow(color: widget.color.withOpacity(0.8), blurRadius: 6)],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  final Color color;
  _OrbitRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const dashLength = 6.0;
    const gapLength = 8.0;
    double circumference = 2 * math.pi * (size.width / 2);
    double offset = 0;

    while (offset < circumference) {
      final startAngle = (offset / circumference) * 2 * math.pi;
      final sweepAngle = (dashLength / circumference) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      offset += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(_OrbitRingPainter old) => false;
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final VoidCallback onTap;

  const _ThemeToggle({
    required this.isDark,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withOpacity(0.2)),
        ),
        child: Icon(
          isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          color: primary,
          size: 19,
        ),
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final String image;
  final bool isDark;
  final Color primary;

  const _CityChip({
    required this.label,
    required this.image,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              image,
              width: 26,
              height: 26,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.75)
                  : Colors.black.withOpacity(0.65),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}


class _LaunchButton extends StatefulWidget {
  final bool isDark;
  final Color primary;

  const _LaunchButton({required this.isDark, required this.primary});

  @override
  State<_LaunchButton> createState() => _LaunchButtonState();
}

class _LaunchButtonState extends State<_LaunchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const EcranPrincipal(),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 19),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDark
                  ? [AppTheme.primaryCyan, const Color(0xFF0080B3)]
                  : [const Color(0xFF0055FF), const Color(0xFF0033CC)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.primary.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'EXPLORER MAINTENANT',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.5,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}