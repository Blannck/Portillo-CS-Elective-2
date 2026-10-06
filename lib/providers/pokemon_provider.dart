import 'package:flutter/foundation.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';

enum PokemonStateStatus { initial, loading, success, error }

enum PokemonSortOption {
  idAsc('ID: Lowest First'),
  idDesc('ID: Highest First'),
  nameAsc('Name: A to Z'),
  nameDesc('Name: Z to A');

  final String label;
  const PokemonSortOption(this.label);
}

enum PokemonIdFilter {
  all('All 30'),
  range1To10('No. 1–10'),
  range11To20('No. 11–20'),
  range21To30('No. 21–30');

  final String label;
  const PokemonIdFilter(this.label);
}

class PokemonProvider extends ChangeNotifier {
  final PokeApiService _apiService;

  PokemonProvider({PokeApiService? apiService})
    : _apiService = apiService ?? PokeApiService();

  PokemonStateStatus _status = PokemonStateStatus.initial;
  List<Pokemon> _pokemonList = <Pokemon>[];
  String _errorMessage = '';
  Pokemon? _selectedPokemon;

  String _searchQuery = '';
  PokemonSortOption _sortOption = PokemonSortOption.idAsc;
  PokemonIdFilter _idFilter = PokemonIdFilter.all;

  PokemonStateStatus get status => _status;
  List<Pokemon> get allPokemonList => List.unmodifiable(_pokemonList);
  String get errorMessage => _errorMessage;
  Pokemon? get selectedPokemon => _selectedPokemon;
  String get searchQuery => _searchQuery;
  PokemonSortOption get sortOption => _sortOption;
  PokemonIdFilter get idFilter => _idFilter;

  bool get isLoading => _status == PokemonStateStatus.loading;
  bool get isSuccess => _status == PokemonStateStatus.success;
  bool get isError => _status == PokemonStateStatus.error;
  bool get isInitial => _status == PokemonStateStatus.initial;

  List<Pokemon> get filteredPokemonList {
    if (_pokemonList.isEmpty) return <Pokemon>[];

    List<Pokemon> list = List<Pokemon>.from(_pokemonList);

    switch (_idFilter) {
      case PokemonIdFilter.range1To10:
        list = list.where((p) => p.id >= 1 && p.id <= 10).toList();
        break;
      case PokemonIdFilter.range11To20:
        list = list.where((p) => p.id >= 11 && p.id <= 20).toList();
        break;
      case PokemonIdFilter.range21To30:
        list = list.where((p) => p.id >= 21 && p.id <= 30).toList();
        break;
      case PokemonIdFilter.all:
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((pokemon) {
        final matchesName = pokemon.name.toLowerCase().contains(query);
        final matchesId =
            pokemon.id.toString() == query ||
            pokemon.formattedId.toLowerCase().contains(query);
        return matchesName || matchesId;
      }).toList();
    }

    switch (_sortOption) {
      case PokemonSortOption.idAsc:
        list.sort((a, b) => a.id.compareTo(b.id));
        break;
      case PokemonSortOption.idDesc:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
      case PokemonSortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case PokemonSortOption.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    return list;
  }

  bool get isFilterEmpty => isSuccess && filteredPokemonList.isEmpty;

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  void setSortOption(PokemonSortOption option) {
    if (_sortOption == option) return;
    _sortOption = option;
    notifyListeners();
  }

  void setIdFilter(PokemonIdFilter filter) {
    if (_idFilter == filter) return;
    _idFilter = filter;
    notifyListeners();
  }

  void selectPokemon(Pokemon pokemon) {
    _selectedPokemon = pokemon;
    notifyListeners();
  }

  void selectPreviousPokemon() {
    if (_selectedPokemon == null || _pokemonList.isEmpty) return;
    final currentIndex = _pokemonList.indexWhere(
      (p) => p.id == _selectedPokemon!.id,
    );
    if (currentIndex > 0) {
      _selectedPokemon = _pokemonList[currentIndex - 1];
    } else {
      _selectedPokemon = _pokemonList.last;
    }
    notifyListeners();
  }

  void selectNextPokemon() {
    if (_selectedPokemon == null || _pokemonList.isEmpty) return;
    final currentIndex = _pokemonList.indexWhere(
      (p) => p.id == _selectedPokemon!.id,
    );
    if (currentIndex != -1 && currentIndex < _pokemonList.length - 1) {
      _selectedPokemon = _pokemonList[currentIndex + 1];
    } else {
      _selectedPokemon = _pokemonList.first;
    }
    notifyListeners();
  }

  void clearSelectedPokemon() {
    _selectedPokemon = null;
    notifyListeners();
  }

  Future<void> fetchPokemonList({int limit = 30}) async {
    _status = PokemonStateStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await _apiService.fetchPokemonList(limit: limit);
      _pokemonList = results;
      _status = PokemonStateStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = PokemonStateStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchPokemonList(limit: 30);
  }
}
