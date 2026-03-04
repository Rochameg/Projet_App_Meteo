import 'package:flutter/material.dart';
import '../models/meteo_model.dart';
import '../theme/app_theme.dart';
import '../services/meteo_service.dart';

class CarteMeteo extends StatefulWidget {
  final DonneesMeteo donnees;
  final int index;
  final bool estSombre;
  final VoidCallback surAppui;

  const CarteMeteo({
    super.key,
    required this.donnees,
    required this.index,
    required this.estSombre,
    required this.surAppui,
  });

  @override
  State<CarteMeteo> createState() => _CarteMeteoState();
}

class _CarteMeteoState extends State<CarteMeteo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controleur;
  late Animation<double> _animEchelle;
  late Animation<double> _animOpacite;

  @override
  void initState() {
    super.initState();
    _controleur = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 100),
    );

    _animEchelle = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controleur, curve: Curves.easeOutBack),
    );
    _animOpacite = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controleur, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controleur.forward();
    });
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = MeteoService.metaVilles[widget.index];
    final couleurAccent = Color((meta['color'] as int?) ?? 0xFF2196F3);
    final estSombre = widget.estSombre;

    return AnimatedBuilder(
      animation: _controleur,
      builder: (context, enfant) {
        return FadeTransition(
          opacity: _animOpacite,
          child: ScaleTransition(
            scale: _animEchelle,
            child: enfant,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.surAppui,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: estSombre ? AppTheme.darkCard : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: couleurAccent.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: couleurAccent.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
             
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: couleurAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: couleurAccent.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.donnees.emojiMeteo,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),

              const SizedBox(width: 16),

             
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        
                        Flexible(
                          child: Text(
                            widget.donnees.ville,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: estSombre ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: couleurAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.donnees.pays,
                            style: TextStyle(
                              color: couleurAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    Text(
                      '${widget.donnees.emojiMeteo} ${_majuscule(widget.donnees.description)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: estSombre
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _PastilleStat(
                          icone: '💧',
                          valeur: '${widget.donnees.humidite.toInt()}%',
                          estSombre: estSombre,
                        ),
                        _PastilleStat(
                          icone: '💨',
                          valeur: '${widget.donnees.vitesseVent.toStringAsFixed(1)}m/s',
                          estSombre: estSombre,
                        ),
                        _PastilleStat(
                          icone: '🌡️',
                          valeur: '${widget.donnees.ressentiThermique.toStringAsFixed(0)}°',
                          estSombre: estSombre,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              
              SizedBox(
                width: 52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.donnees.temperature.toStringAsFixed(0)}°',
                      style: TextStyle(
                        color: couleurAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    Text(
                      'C',
                      style: TextStyle(
                        color: couleurAccent.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: estSombre
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.3),
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _majuscule(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _PastilleStat extends StatelessWidget {
  final String icone;
  final String valeur;
  final bool estSombre;

  const _PastilleStat({
    required this.icone,
    required this.valeur,
    required this.estSombre,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: estSombre
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icone, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            valeur,
            style: TextStyle(
              color: estSombre ? Colors.white70 : Colors.black54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}