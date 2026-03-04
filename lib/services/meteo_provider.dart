import 'package:flutter/material.dart';
import '../models/meteo_model.dart';
import 'meteo_service.dart';

enum EtatApp { inactif, chargement, succes, erreur }

class MeteoFournisseur extends ChangeNotifier {
  final MeteoService _service = MeteoService();

  EtatApp _etat = EtatApp.inactif;
  List<DonneesMeteo> _donneesMeteo = [];
  String _messageErreur = '';
  double _progression = 0.0;
  int _nombreCharge = 0;
  bool _estModeSombre = true;

  EtatApp get etat => _etat;
  List<DonneesMeteo> get donneesMeteo => _donneesMeteo;
  String get messageErreur => _messageErreur;
  double get progression => _progression;
  int get nombreCharge => _nombreCharge;
  bool get estModeSombre => _estModeSombre;

  void basculerTheme() {
    _estModeSombre = !_estModeSombre;
    notifyListeners();
  }

  void reinitialiser() {
    _etat = EtatApp.inactif;
    _donneesMeteo = [];
    _messageErreur = '';
    _progression = 0.0;
    _nombreCharge = 0;
    notifyListeners();
  }

  Future<void> chargerMeteo() async {
    _etat = EtatApp.chargement;
    _progression = 0.0;
    _nombreCharge = 0;
    _donneesMeteo = [];
    _messageErreur = '';
    notifyListeners();

    try {
      final total = MeteoService.villes.length;

      await _service.recupererToutesLesVilles(
        surProgression: (index, donnees) {
          _nombreCharge = index + 1;
          _progression = (index + 1) / total;
          _donneesMeteo.add(donnees);
          notifyListeners();
        },
      );

      _etat = EtatApp.succes;
      notifyListeners();
    } catch (e) {
      _etat = EtatApp.erreur;
      _messageErreur = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}