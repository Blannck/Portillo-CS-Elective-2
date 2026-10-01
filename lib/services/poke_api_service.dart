import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  final http.Client _client;

  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

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

        return results
            .map((item) => Pokemon.fromJson(item as Map<String, dynamic>))
            .toList();
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
