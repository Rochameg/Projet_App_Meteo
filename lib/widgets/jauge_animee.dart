import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class JaugeAnimee extends StatefulWidget {
  final double progression;
  final bool estSombre;

  const JaugeAnimee({
    super.key,
    required this.progression,
    required this.estSombre,
  });

  @override
  State<JaugeAnimee> createState() => _JaugeAnimeeState();
}

class _JaugeAnimeeState extends State<JaugeAnimee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controleurEclat;
  late Animation<double> _animEclat;

  @override
  void initState() {
    super.initState();
    _controleurEclat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animEclat = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controleurEclat, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controleurEclat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couleurPrimaire = widget.estSombre ? AppTheme.primaryCyan : AppTheme.primaryBlue;

    return AnimatedBuilder(
      animation: _animEclat,
      builder: (context, _) {
        return SizedBox(
          width: 240,
          height: 240,
          child: CustomPaint(
            painter: _PeintrreJauge(
              progression: widget.progression,
              estSombre: widget.estSombre,
              intensiteEclat: _animEclat.value,
              couleurPrimaire: couleurPrimaire,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(widget.progression * 100).toInt()}%',
                    style: TextStyle(
                      color: couleurPrimaire,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CHARGEMENT',
                    style: TextStyle(
                      color: couleurPrimaire.withOpacity(0.6),
                      fontSize: 10,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
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

class _PeintrreJauge extends CustomPainter {
  final double progression;
  final bool estSombre;
  final double intensiteEclat;
  final Color couleurPrimaire;

  _PeintrreJauge({
    required this.progression,
    required this.estSombre,
    required this.intensiteEclat,
    required this.couleurPrimaire,
  });

  @override
  void paint(Canvas canevas, Size taille) {
    final centre = Offset(taille.width / 2, taille.height / 2);
    final rayon = math.min(taille.width, taille.height) / 2 - 20;
    const angleDepart = -math.pi * 0.8;
    const balayageTotal = math.pi * 1.6;

    // Fond de la piste
    final peinturePiste = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = estSombre
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.08);
    canevas.drawArc(
      Rect.fromCircle(center: centre, radius: rayon),
      angleDepart,
      balayageTotal,
      false,
      peinturePiste,
    );

    // Graduations
    for (int i = 0; i <= 10; i++) {
      final angle = angleDepart + (balayageTotal * i / 10);
      final pointExterieur = Offset(
        centre.dx + (rayon + 12) * math.cos(angle),
        centre.dy + (rayon + 12) * math.sin(angle),
      );
      final pointInterieur = Offset(
        centre.dx + (rayon - 20) * math.cos(angle),
        centre.dy + (rayon - 20) * math.sin(angle),
      );
      final peintureGraduation = Paint()
        ..color = couleurPrimaire.withOpacity(0.3)
        ..strokeWidth = i % 5 == 0 ? 2 : 1;
      canevas.drawLine(pointInterieur, pointExterieur, peintureGraduation);
    }

    if (progression > 0) {
      // Couche d'éclat
      final peintureEclat = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * intensiteEclat)
        ..color = couleurPrimaire.withOpacity(0.4 * intensiteEclat);
      canevas.drawArc(
        Rect.fromCircle(center: centre, radius: rayon),
        angleDepart,
        balayageTotal * progression,
        false,
        peintureEclat,
      );

      // Arc de progression
      final peintureProgression = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: angleDepart,
          endAngle: angleDepart + balayageTotal * progression,
          colors: [
            couleurPrimaire.withOpacity(0.6),
            couleurPrimaire,
          ],
          transform: GradientRotation(angleDepart),
        ).createShader(Rect.fromCircle(center: centre, radius: rayon));
      canevas.drawArc(
        Rect.fromCircle(center: centre, radius: rayon),
        angleDepart,
        balayageTotal * progression,
        false,
        peintureProgression,
      );

      // Point de pointe
      final anglePointe = angleDepart + balayageTotal * progression;
      final pointPointe = Offset(
        centre.dx + rayon * math.cos(anglePointe),
        centre.dy + rayon * math.sin(anglePointe),
      );
      final peintureEclatPoint = Paint()
        ..color = couleurPrimaire.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canevas.drawCircle(pointPointe, 14, peintureEclatPoint);
      canevas.drawCircle(pointPointe, 8, Paint()..color = couleurPrimaire);
      canevas.drawCircle(pointPointe, 4, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_PeintrreJauge ancien) =>
      ancien.progression != progression ||
      ancien.intensiteEclat != intensiteEclat ||
      ancien.estSombre != estSombre;
}