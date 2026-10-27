import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  final http.Client _client;

  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  static const Map<int, List<String>> _fallbackTypes = {
    1: ['grass', 'poison'],
    2: ['grass', 'poison'],
    3: ['grass', 'poison'],
    4: ['fire'],
    5: ['fire'],
    6: ['fire', 'flying'],
    7: ['water'],
    8: ['water'],
    9: ['water'],
    10: ['bug'],
    11: ['bug'],
    12: ['bug', 'flying'],
    13: ['bug', 'poison'],
    14: ['bug', 'poison'],
    15: ['bug', 'poison'],
    16: ['normal', 'flying'],
    17: ['normal', 'flying'],
    18: ['normal', 'flying'],
    19: ['normal'],
    20: ['normal'],
    21: ['normal', 'flying'],
    22: ['normal', 'flying'],
    23: ['poison'],
    24: ['poison'],
    25: ['electric'],
    26: ['electric'],
    27: ['ground'],
    28: ['ground'],
    29: ['poison'],
    30: ['poison'],
  };

  Future<List<Pokemon>> fetchPokemonList({int limit = 30}) async {
    final uri = Uri.parse('$_baseUrl/pokemon?limit=$limit');

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic>? results = data['results'] as List<dynamic>?;

        if (results == null || results.isEmpty) {
          return <Pokemon>[];
        }

        final detailFutures = results.map((item) async {
          final map = item as Map<String, dynamic>;
          final basicPokemon = Pokemon.fromListJson(map);
          final url = map['url'] as String? ?? '';

          if (url.isNotEmpty) {
            try {
              final detailRes = await _client
                  .get(Uri.parse(url))
                  .timeout(const Duration(seconds: 5));
              if (detailRes.statusCode == 200) {
                final detailJson =
                    jsonDecode(detailRes.body) as Map<String, dynamic>;
                return Pokemon.fromDetailJson(detailJson);
              }
            } catch (_) {}
          }

          final types = _fallbackTypes[basicPokemon.id] ?? const [];
          return basicPokemon.copyWith(types: types);
        }).toList();

        return await Future.wait(detailFutures);
      } else {
        throw HttpException(
          'Server returned error code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException(
        'No Internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw TimeoutException(
        'Request timed out. The server took too long to respond.',
      );
    } on FormatException catch (e) {
      throw FormatException('Failed to parse API response: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
