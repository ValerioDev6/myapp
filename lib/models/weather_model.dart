class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['current']['temp'],
      description: json['current']['condition']['text'],
      iconCode: json['current']['condition']['code'],
    );
  }
}
