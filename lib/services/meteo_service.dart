import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meteo_model.dart';

class MeteoService {
  
  static const String _cleApi = '5d9fd4d1f5d059439d8a13481e6962c1';
  static const String _urlBase =
      'https://api.openweathermap.org/data/2.5/weather';

  static const List<String> villes = [
    'Paris',
    'Tokyo',
    'New York',
    'Sydney',
    'Dubai',
  ];

  // static const List<Map<String, dynamic>> metaVilles = [
  //   {'nom': 'Paris',    'emoji': '🗼', 'couleur': 0xFF6C63FF},
  //   {'nom': 'Tokyo',    'emoji': '🗾', 'couleur': 0xFFFF6B6B},
  //   {'nom': 'New York', 'emoji': '🗽', 'couleur': 0xFF4ECDC4},
  //   {'nom': 'Sydney',   'emoji': '🦘', 'couleur': 0xFFFFE66D},
  //   {'nom': 'Dubai',    'emoji': '🏙️', 'couleur': 0xFFFF9F43},
  // ];

  static const List<Map<String, String>> metaVilles = [
    {
      'nom': 'Paris',
      'image': 'assets/images/paris.jpg',
    },
    {
      'nom': 'Tokyo',
      'image': 'assets/images/tokyo.jpg',
    },
    {
      'nom': 'New York',
      'image': 'assets/images/newyork.jpg',
    },
    {
      'nom': 'Sydney',
      'image': 'assets/images/sydney.jpg',
    },
    {
      'nom': 'Dubai',
      'image': 'assets/images/dubai.jpg',
    },
  ];

  Future<DonneesMeteo> recupererMeteo(String ville) async {
    final uri = Uri.parse(
      '$_urlBase?q=$ville&appid=$_cleApi&units=metric&lang=fr',
    );

    final reponse = await http.get(uri).timeout(
          const Duration(seconds: 10),
        );

    if (reponse.statusCode == 200) {
      final json = jsonDecode(reponse.body);
      return DonneesMeteo.depuisJson(json);
    } else if (reponse.statusCode == 401) {
      throw Exception(
          'Clé API invalide. Veuillez configurer votre clé OpenWeatherMap.');
    } else if (reponse.statusCode == 404) {
      throw Exception('Ville "$ville" introuvable.');
    } else {
      throw Exception('Erreur API : ${reponse.statusCode}');
    }
  }

  Future<List<DonneesMeteo>> recupererToutesLesVilles({
    void Function(int index, DonneesMeteo donnees)? surProgression,
  }) async {
    final List<DonneesMeteo> resultats = [];

    for (int i = 0; i < villes.length; i++) {
      final donnees = await recupererMeteo(villes[i]);
      resultats.add(donnees);
      if (surProgression != null) {
        surProgression(i, donnees);
      }
      // Courte pause entre les requêtes
      if (i < villes.length - 1) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    return resultats;
  }
}