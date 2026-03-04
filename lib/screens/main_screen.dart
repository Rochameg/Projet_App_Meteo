
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meteo_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/jauge_animee.dart';
import '../widgets/meteo_carte.dart';
import 'detail_screen.dart';

class EcranPrincipal extends StatefulWidget {
  const EcranPrincipal({super.key});

  @override
  State<EcranPrincipal> createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal>
    with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;
  Timer? _msgTimer;
  int _msgIndex = 0;

  final List<Map<String, String>> _messages = [
    {'emoji': '🌐', 'text': 'Connexion aux serveurs météo…'},
    {'emoji': '⚡', 'text': 'Récupération des données…'},
    {'emoji': '⏳', 'text': 'Calcul des conditions…'},
  ];

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut),
    );

    _startMsgRotation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeteoFournisseur>().chargerMeteo();
    });
  }

  void _startMsgRotation() {
    _msgTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted)
        setState(() => _msgIndex = (_msgIndex + 1) % _messages.length);
    });
  }

  void _animateTo(double target) {
    _progressAnim = Tween<double>(
      begin: _progressAnim.value,
      end: target,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl.forward(from: 0);
  }

  void _resetAndReload(MeteoFournisseur provider) {
    provider.reinitialiser();
    setState(() {
      _msgIndex = 0;
      _animateTo(0);
      _startMsgRotation();
    });
    provider.chargerMeteo();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _msgTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MeteoFournisseur>(
      builder: (context, provider, _) {
        
        if (provider.etat == EtatApp.chargement) {
          final target = provider.progression;
          if ((target - _progressAnim.value).abs() > 0.01) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _animateTo(target);
            });
          }
        } else if (provider.etat == EtatApp.succes) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _animateTo(1.0);
          });
        }

        final isDark = provider.estModeSombre;
        final primary = isDark ? AppTheme.primaryCyan : AppTheme.primaryBlue;

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF080C14) : const Color(0xFFF0F4FF),
          appBar: _buildAppBar(isDark, primary, provider),
          body: _buildBody(context, provider, isDark, primary),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      bool isDark, Color primary, MeteoFournisseur provider) {
    return AppBar(
      backgroundColor:
          isDark ? const Color(0xFF080C14) : const Color(0xFFF0F4FF),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: primary, size: 18),
        onPressed: () {
          provider.reinitialiser();
          Navigator.pop(context);
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: primary.withOpacity(0.6), blurRadius: 6)
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'MÉTÉO MONDIALE',
            style: TextStyle(
              color: primary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            color: primary,
            size: 19,
          ),
          onPressed: provider.basculerTheme,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, MeteoFournisseur provider,
      bool isDark, Color primary) {
    switch (provider.etat) {
      case EtatApp.inactif:
      case EtatApp.chargement:
        return _LoadingView(
          progressAnim: _progressAnim,
          msgIndex: _msgIndex,
          messages: _messages,
          provider: provider,
          isDark: isDark,
          primary: primary,
        );
      case EtatApp.erreur:
        return _ErrorView(
          provider: provider,
          isDark: isDark,
          primary: primary,
          onRetry: () {
            provider.chargerMeteo();
            setState(() {
              _msgIndex = 0;
              _animateTo(0);
              _startMsgRotation();
            });
          },
          onBack: () {
            provider.reinitialiser();
            Navigator.pop(context);
          },
        );
      case EtatApp.succes:
        _msgTimer?.cancel();
        return _SuccessView(
          provider: provider,
          isDark: isDark,
          primary: primary,
          onRefresh: () => _resetAndReload(provider),
          onCityTap: (i) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => EcranDetail(
                  donnees: provider.donneesMeteo[i],
                  index: i,
                ),
                transitionsBuilder: (_, anim, __, child) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOutCubic)),
                    child: child,
                  ),
                ),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
        );
    }
  }
}


class _LoadingView extends StatelessWidget {
  final Animation<double> progressAnim;
  final int msgIndex;
  final List<Map<String, String>> messages;
  final MeteoFournisseur provider;
  final bool isDark;
  final Color primary;

  const _LoadingView({
    required this.progressAnim,
    required this.msgIndex,
    required this.messages,
    required this.provider,
    required this.isDark,
    required this.primary,
  });

  static const List<Map<String, String>> _cities = [
    {'name': 'Paris', 'img': 'assets/images/paris.jpg'},
    {'name': 'Tokyo', 'img': 'assets/images/tokyo.jpg'},
    {'name': 'New York', 'img': 'assets/images/new_york.jpg'},
    {'name': 'Sydney', 'img': 'assets/images/sydney.jpg'},
    {'name': 'Dubai', 'img': 'assets/images/dubai.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progressAnim,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),

              
              JaugeAnimee(progression: progressAnim.value, estSombre: isDark),

              const SizedBox(height: 36),

              
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Row(
                  key: ValueKey(msgIndex),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      messages[msgIndex]['emoji']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      messages[msgIndex]['text']!,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black.withOpacity(0.5),
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: primary.withOpacity(0.2)),
                ),
                child: Text(
                  '${(progressAnim.value * 100).toInt()}%  CHARGÉ',
                  style: TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              
              Column(
                children: List.generate(5, (i) {
                  final loaded = i < provider.nombreCharge;
                  final loading = i == provider.nombreCharge &&
                      provider.etat == EtatApp.chargement;
                  final city = _cities[i];
                  final data = loaded && i < provider.donneesMeteo.length
                      ? provider.donneesMeteo[i]
                      : null;

                  return _CityLoadRow(
                    cityName: city['name']!,
                    cityImage: city['img']!,
                    loaded: loaded,
                    loading: loading,
                    isDark: isDark,
                    primary: primary,
                    temp: data != null
                        ? '${data.temperature.toStringAsFixed(0)}°C ${data.emojiMeteo}'
                        : null,
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CityLoadRow extends StatelessWidget {
  final String cityName;
  final String cityImage;
  final bool loaded;
  final bool loading;
  final bool isDark;
  final Color primary;
  final String? temp;

  const _CityLoadRow({
    required this.cityName,
    required this.cityImage,
    required this.loaded,
    required this.loading,
    required this.isDark,
    required this.primary,
    this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: loaded
            ? primary.withOpacity(isDark ? 0.07 : 0.05)
            : isDark
                ? const Color(0xFF111827).withOpacity(0.6)
                : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: loaded
              ? primary.withOpacity(0.25)
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              cityImage,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),

          
          Expanded(
            child: Text(
              cityName,
              style: TextStyle(
                color: loaded
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark
                        ? Colors.white30
                        : Colors.black.withOpacity(0.28)),
                fontWeight: loaded ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),

          
          if (loaded && temp != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                temp!,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            )
          else if (loading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primary,
              ),
            )
          else
            Icon(
              Icons.radio_button_unchecked,
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.15),
              size: 18,
            ),
        ],
      ),
    );
  }
}


class _SuccessView extends StatelessWidget {
  final MeteoFournisseur provider;
  final bool isDark;
  final Color primary;
  final VoidCallback onRefresh;
  final ValueChanged<int> onCityTap;

  const _SuccessView({
    required this.provider,
    required this.isDark,
    required this.primary,
    required this.onRefresh,
    required this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle,
                    color: Color(0xFF22C55E), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${provider.donneesMeteo.length} villes chargées',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Appuyez pour voir les détails',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withOpacity(0.7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 15),
                      SizedBox(width: 5),
                      Text(
                        'Actualiser',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

       
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.donneesMeteo.length,
            itemBuilder: (context, i) {
              return CarteMeteo(
                donnees: provider.donneesMeteo[i],
                index: i,
                estSombre: isDark,
                surAppui: () => onCityTap(i),
              );
            },
          ),
        ),
      ],
    );
  }
}


class _ErrorView extends StatelessWidget {
  final MeteoFournisseur provider;
  final bool isDark;
  final Color primary;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ErrorView({
    required this.provider,
    required this.isDark,
    required this.primary,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.35),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text('⚠️', style: TextStyle(fontSize: 44)),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'CONNEXION ÉCHOUÉE',
              style: TextStyle(
                color: const Color(0xFFEF4444).withOpacity(0.9),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.18),
                ),
              ),
              child: Text(
                provider.messageErreur,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFDC2626),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 32),

            
            GestureDetector(
              onTap: onRetry,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 17),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'RÉESSAYER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextButton(
              onPressed: onBack,
              child: Text(
                '← Retour à l\'accueil',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
