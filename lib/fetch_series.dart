import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itr_proj/cricket_series_model.dart';

Future<List<CricketSeries>> fetchSeries() async {
  final response = await http.get(Uri.parse(
      'https://api.cricapi.com/v1/series?apikey=837ed22d-4bcd-463b-a78a-a617ac7d20c2&offset=0'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final rawList = data['data'] as List<dynamic>? ?? [];
    return rawList.map((json) => CricketSeries.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load series (status: ${response.statusCode})');
  }
}

