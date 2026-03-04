class DonneesMeteo {
  final String ville;
  final String pays;
  final double temperature;
  final double ressentiThermique;
  final double humidite;
  final double vitesseVent;
  final String description;
  final String icone;
  final double lat;
  final double lon;
  final int pression;
  final int visibilite;
  final double temperatureMin;
  final double temperatureMax;

  DonneesMeteo({
    required this.ville,
    required this.pays,
    required this.temperature,
    required this.ressentiThermique,
    required this.humidite,
    required this.vitesseVent,
    required this.description,
    required this.icone,
    required this.lat,
    required this.lon,
    required this.pression,
    required this.visibilite,
    required this.temperatureMin,
    required this.temperatureMax,
  });

  factory DonneesMeteo.depuisJson(Map<String, dynamic> json) {
    return DonneesMeteo(
      ville: json['name'] ?? '',
      pays: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      ressentiThermique: (json['main']['feels_like'] as num).toDouble(),
      humidite: (json['main']['humidity'] as num).toDouble(),
      vitesseVent: (json['wind']['speed'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icone: json['weather'][0]['icon'] ?? '01d',
      lat: (json['coord']['lat'] as num).toDouble(),
      lon: (json['coord']['lon'] as num).toDouble(),
      pression: (json['main']['pressure'] as num).toInt(),
      visibilite: (json['visibility'] as num).toInt(),
      temperatureMin: (json['main']['temp_min'] as num).toDouble(),
      temperatureMax: (json['main']['temp_max'] as num).toDouble(),
    );
  }

  String get emojiMeteo {
    final code = icone.substring(0, 2);
    switch (code) {
      case '01': return '☀️';
      case '02': return '🌤️';
      case '03': return '⛅';
      case '04': return '☁️';
      case '09': return '🌧️';
      case '10': return '🌦️';
      case '11': return '⛈️';
      case '13': return '❄️';
      case '50': return '🌫️';
      default: return '🌡️';
    }
  }

  String get urlIcone => 'https://openweathermap.org/img/wn/$icone@2x.png';
}