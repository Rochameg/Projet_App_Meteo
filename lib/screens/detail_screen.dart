import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/meteo_model.dart';
import '../services/meteo_provider.dart';
import '../services/meteo_service.dart';
import '../theme/app_theme.dart';

class EcranDetail extends StatefulWidget {
  final DonneesMeteo donnees;
  final int index;

  const EcranDetail({
    super.key,
    required this.donnees,
    required this.index,
  });

  @override
  State<EcranDetail> createState() => _EcranDetailState();
}

class _EcranDetailState extends State<EcranDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _openMaps() async {
    final lat = widget.donnees.lat;
    final lon = widget.donnees.lon;
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeteoFournisseur>();
    final isDark = provider.estModeSombre;
    final meta = MeteoService.metaVilles[widget.index];
    final accent =
        meta['color'] != null ? Color(meta['color'] as int) : Colors.blueAccent;
    final primary = isDark ? AppTheme.primaryCyan : AppTheme.primaryBlue;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF080C14) : const Color(0xFFF0F4FF),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(),
            slivers: [
              
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                stretch: true,
                backgroundColor:
                    isDark ? const Color(0xFF0D111C) : Colors.white,
                elevation: 0,
                leading: _BackButton(isDark: isDark, primary: primary),
                actions: [
                  _MapButton(onTap: _openMaps, primary: primary),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: _HeroHeader(
                    donnees: widget.donnees,
                    meta: meta,
                    accent: accent,
                    isDark: isDark,
                    ctrl: _entryCtrl,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      _SectionHeader(
                        title: 'DONNÉES MÉTÉO',
                        icon: '🌡️',
                        isDark: isDark,
                        primary: primary,
                      ),
                      const SizedBox(height: 16),

                      
                      Row(
                        children: [
                          Expanded(
                            child: _PrimaryStatCard(
                              icon: '🌡️',
                              label: 'TEMPÉRATURE',
                              value:
                                  '${widget.donnees.temperature.toStringAsFixed(1)}°',
                              sub:
                                  'Min ${widget.donnees.temperatureMin.toStringAsFixed(0)}°  ·  Max ${widget.donnees.temperatureMax.toStringAsFixed(0)}°',
                              color: accent,
                              isDark: isDark,
                              isLarge: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PrimaryStatCard(
                              icon: '🤔',
                              label: 'RESSENTI',
                              value:
                                  '${widget.donnees.ressentiThermique.toStringAsFixed(1)}°',
                              sub: widget.donnees.description,
                              color: accent.withBlue(220),
                              isDark: isDark,
                              isLarge: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.7,
                        children: [
                          _StatCard(
                            icon: '💧',
                            label: 'HUMIDITÉ',
                            value: '${widget.donnees.humidite.toInt()}%',
                            sub: _humidityLabel(widget.donnees.humidite),
                            color: const Color(0xFF4ECDC4),
                            isDark: isDark,
                            progress: widget.donnees.humidite / 100,
                          ),
                          _StatCard(
                            icon: '💨',
                            label: 'VENT',
                            value:
                                '${widget.donnees.vitesseVent.toStringAsFixed(1)} m/s',
                            sub:
                                '${(widget.donnees.vitesseVent * 3.6).toStringAsFixed(0)} km/h',
                            color: const Color(0xFF45B7D1),
                            isDark: isDark,
                            progress:
                                (widget.donnees.vitesseVent / 30).clamp(0, 1),
                          ),
                          _StatCard(
                            icon: '🔵',
                            label: 'PRESSION',
                            value: '${widget.donnees.pression}',
                            sub:
                                'hPa · ${_pressureLabel(widget.donnees.pression)}',
                            color: const Color(0xFF96CEB4),
                            isDark: isDark,
                            progress: ((widget.donnees.pression - 980) / 60)
                                .clamp(0, 1),
                          ),
                          _StatCard(
                            icon: '👁️',
                            label: 'VISIBILITÉ',
                            value:
                                '${(widget.donnees.visibilite / 1000).toStringAsFixed(1)} km',
                            sub: _visibilityLabel(widget.donnees.visibilite),
                            color: const Color(0xFFDDA0DD),
                            isDark: isDark,
                            progress:
                                (widget.donnees.visibilite / 10000).clamp(0, 1),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      
                      _SectionHeader(
                        title: 'LOCALISATION',
                        icon: '📍',
                        isDark: isDark,
                        primary: primary,
                      ),
                      const SizedBox(height: 16),
                      _MapCard(
                        donnees: widget.donnees,
                        accent: accent,
                        isDark: isDark,
                        onMaps: _openMaps,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _humidityLabel(double h) {
    if (h < 30) return 'Air très sec';
    if (h < 50) return 'Confortable';
    if (h < 70) return 'Légèrement humide';
    return 'Très humide';
  }

  String _pressureLabel(int p) {
    if (p < 1000) return 'Basse pression';
    if (p < 1015) return 'Normale';
    return 'Haute pression';
  }

  String _visibilityLabel(int v) {
    if (v < 1000) return 'Très faible';
    if (v < 5000) return 'Réduite';
    if (v < 10000) return 'Modérée';
    return 'Excellente';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<AnimationController>('_entryCtrl', _entryCtrl));
  }
}


class _BackButton extends StatelessWidget {
  final bool isDark;
  final Color primary;
  const _BackButton({required this.isDark, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              const Icon(Icons.arrow_back_ios, color: Colors.white, size: 17),
        ),
      ),
    );
  }
}


class _MapButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color primary;
  const _MapButton({required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.map_outlined, color: Colors.white, size: 15),
            SizedBox(width: 6),
            Text(
              'Maps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _HeroHeader extends StatelessWidget {
  final DonneesMeteo donnees;
  final Map<String, dynamic> meta;
  final Color accent;
  final bool isDark;
  final AnimationController ctrl;

  const _HeroHeader({
    required this.donnees,
    required this.meta,
    required this.accent,
    required this.isDark,
    required this.ctrl,
  });

  static const Map<String, String> _assets = {
    'Paris': 'assets/images/paris.jpg',
    'Tokyo': 'assets/images/tokyo.jpg',
    'New York': 'assets/images/new_york.jpg',
    'Sydney': 'assets/images/sydney.jpg',
    'Dubai': 'assets/images/dubai.jpg',
  };

  @override
  Widget build(BuildContext context) {
    final assetPath = _assets[donnees.ville] ?? 'assets/images/paris.jpg';

    return Stack(
      fit: StackFit.expand,
      children: [
        
        Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.5), accent.withOpacity(0.1)],
              ),
            ),
            child: Center(
              child: Text(meta['emoji'] as String,
                  style: const TextStyle(fontSize: 80)),
            ),
          ),
        ),

        
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.35, 1.0],
              ),
            ),
          ),
        ),

        
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 3,
          child: Container(color: accent),
        ),

        
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: FadeTransition(
            opacity: ctrl,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${donnees.pays}  ·  ${donnees.lat.toStringAsFixed(1)}°N',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          donnees.ville,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 16)
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              donnees.emojiMeteo,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              donnees.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                                shadows: const [
                                  Shadow(color: Colors.black45, blurRadius: 8)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ShaderMask(
                        shaderCallback: (r) => LinearGradient(
                          colors: [Colors.white, accent.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(r),
                        child: Text(
                          '${donnees.temperature.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 20)
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'Celsius',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  final String icon;
  final bool isDark;
  final Color primary;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: primary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(height: 1, color: primary.withOpacity(0.15)),
        ),
      ],
    );
  }
}


class _PrimaryStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String sub;
  final Color color;
  final bool isDark;
  final bool isLarge;

  const _PrimaryStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.isDark,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.08 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isLarge ? 36 : 26,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String sub;
  final Color color;
  final bool isDark;
  final double progress;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.isDark,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.06 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black38,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _MapCard extends StatelessWidget {
  final DonneesMeteo donnees;
  final Color accent;
  final bool isDark;
  final VoidCallback onMaps;

  const _MapCard({
    required this.donnees,
    required this.accent,
    required this.isDark,
    required this.onMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isDark ? 0.08 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(donnees.lat, donnees.lon),
                      initialZoom: 12,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.weather_app',
                        tileProvider: NetworkTileProvider(),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(donnees.lat, donnees.lon),
                            width: 60,
                            height: 70,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withOpacity(0.5),
                                        blurRadius: 16,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                Container(width: 2, height: 8, color: accent),
                                Container(
                                  width: 8,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${donnees.lat.toStringAsFixed(4)}, ${donnees.lon.toStringAsFixed(4)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.place, color: accent, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donnees.ville,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Lat ${donnees.lat.toStringAsFixed(4)}  ·  Lon ${donnees.lon.toStringAsFixed(4)}',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onMaps,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent, accent.withOpacity(0.7)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.open_in_new,
                              color: Colors.white, size: 13),
                          SizedBox(width: 6),
                          Text(
                            'Google Maps',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
