import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class PokemonState {
  final PokemonStateStatus status;
  final List<Pokemon> allPokemon;
  final String errorMessage;
  final Pokemon? selectedPokemon;
  final String searchQuery;
  final PokemonSortOption sortOption;
  final PokemonIdFilter idFilter;
  final Set<int> favorites;
  final Map<int, String> nicknames;
  final String? selectedType;
  final bool isFavoritesPanelExpanded;

  const PokemonState({
    this.status = PokemonStateStatus.initial,
    this.allPokemon = const [],
    this.errorMessage = '',
    this.selectedPokemon,
    this.searchQuery = '',
    this.sortOption = PokemonSortOption.idAsc,
    this.idFilter = PokemonIdFilter.all,
    this.favorites = const {},
    this.nicknames = const {},
    this.selectedType,
    this.isFavoritesPanelExpanded = false,
  });

  bool get isLoading => status == PokemonStateStatus.loading;
  bool get isSuccess => status == PokemonStateStatus.success;
  bool get isError => status == PokemonStateStatus.error;
  bool get isInitial => status == PokemonStateStatus.initial;

  bool isFavorite(int id) => favorites.contains(id);

  String? getNickname(int id) {
    final nick = nicknames[id];
    return (nick != null && nick.trim().isNotEmpty) ? nick.trim() : null;
  }

  List<Pokemon> get favoritePokemonList {
    return allPokemon.where((p) => favorites.contains(p.id)).toList();
  }

  List<String> get availableTypes {
    final set = <String>{};
    for (final p in allPokemon) {
      for (final t in p.types) {
        if (t.isNotEmpty) set.add(t.toLowerCase());
      }
    }
    final sorted = set.toList()..sort();
    return sorted;
  }

  List<Pokemon> get filteredPokemonList {
    if (allPokemon.isEmpty) return <Pokemon>[];

    List<Pokemon> list = List<Pokemon>.from(allPokemon);

    if (selectedType != null &&
        selectedType!.isNotEmpty &&
        selectedType!.toLowerCase() != 'all') {
      final targetType = selectedType!.toLowerCase();
      list = list.where((p) {
        return p.types.any((t) => t.toLowerCase() == targetType);
      }).toList();
    }

    switch (idFilter) {
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

    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      list = list.where((pokemon) {
        final matchesName = pokemon.name.toLowerCase().contains(query);
        final matchesId =
            pokemon.id.toString() == query ||
            pokemon.formattedId.toLowerCase().contains(query);
        final nick = getNickname(pokemon.id)?.toLowerCase();
        final matchesNick = nick != null && nick.contains(query);
        return matchesName || matchesId || matchesNick;
      }).toList();
    }

    switch (sortOption) {
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

  PokemonState copyWith({
    PokemonStateStatus? status,
    List<Pokemon>? allPokemon,
    String? errorMessage,
    Pokemon? selectedPokemon,
    bool clearSelectedPokemon = false,
    String? searchQuery,
    PokemonSortOption? sortOption,
    PokemonIdFilter? idFilter,
    Set<int>? favorites,
    Map<int, String>? nicknames,
    String? selectedType,
    bool clearSelectedType = false,
    bool? isFavoritesPanelExpanded,
  }) {
    return PokemonState(
      status: status ?? this.status,
      allPokemon: allPokemon ?? this.allPokemon,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPokemon: clearSelectedPokemon
          ? null
          : (selectedPokemon ?? this.selectedPokemon),
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      idFilter: idFilter ?? this.idFilter,
      favorites: favorites ?? this.favorites,
      nicknames: nicknames ?? this.nicknames,
      selectedType: clearSelectedType
          ? null
          : (selectedType ?? this.selectedType),
      isFavoritesPanelExpanded:
          isFavoritesPanelExpanded ?? this.isFavoritesPanelExpanded,
    );
  }
}

class PokemonNotifier extends Notifier<PokemonState> {
  late final PokeApiService _apiService;

  @override
  PokemonState build() {
    _apiService = PokeApiService();
    return const PokemonState();
  }

  Future<void> fetchPokemonList({int limit = 30}) async {
    state = state.copyWith(
      status: PokemonStateStatus.loading,
      errorMessage: '',
    );

    try {
      final results = await _apiService.fetchPokemonList(limit: limit);

      Pokemon? updatedSelected;
      if (state.selectedPokemon != null) {
        final idx = results.indexWhere(
          (p) => p.id == state.selectedPokemon!.id,
        );
        if (idx != -1) updatedSelected = results[idx];
      }

      state = state.copyWith(
        status: PokemonStateStatus.success,
        allPokemon: results,
        selectedPokemon: updatedSelected,
      );
    } catch (e) {
      state = state.copyWith(
        status: PokemonStateStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void setNickname(int pokemonId, String nickname) {
    final updatedNicknames = Map<int, String>.from(state.nicknames);
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      updatedNicknames.remove(pokemonId);
    } else {
      updatedNicknames[pokemonId] = trimmed;
    }
    state = state.copyWith(nicknames: updatedNicknames);
  }

  void removeNickname(int pokemonId) {
    final updatedNicknames = Map<int, String>.from(state.nicknames);
    updatedNicknames.remove(pokemonId);
    state = state.copyWith(nicknames: updatedNicknames);
  }

  void toggleFavorite(int pokemonId) {
    final updatedFavorites = Set<int>.from(state.favorites);
    if (updatedFavorites.contains(pokemonId)) {
      updatedFavorites.remove(pokemonId);
    } else {
      updatedFavorites.add(pokemonId);
    }
    state = state.copyWith(favorites: updatedFavorites);
  }

  void addFavorite(int pokemonId) {
    if (state.favorites.contains(pokemonId)) return;
    final updatedFavorites = Set<int>.from(state.favorites)..add(pokemonId);
    state = state.copyWith(favorites: updatedFavorites);
  }

  void removeFavorite(int pokemonId) {
    if (!state.favorites.contains(pokemonId)) return;
    final updatedFavorites = Set<int>.from(state.favorites)..remove(pokemonId);
    state = state.copyWith(favorites: updatedFavorites);
  }

  void toggleFavoritesPanel() {
    state = state.copyWith(
      isFavoritesPanelExpanded: !state.isFavoritesPanelExpanded,
    );
  }

  void setFavoritesPanelExpanded(bool expanded) {
    state = state.copyWith(isFavoritesPanelExpanded: expanded);
  }

  void setTypeFilter(String? type) {
    if (type == null || type.isEmpty || type.trim().toLowerCase() == 'all') {
      clearTypeFilter();
    } else {
      state = state.copyWith(selectedType: type.trim().toLowerCase());
    }
  }

  void clearTypeFilter() {
    state = state.copyWith(clearSelectedType: true);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearchQuery() {
    state = state.copyWith(searchQuery: '');
  }

  void setSortOption(PokemonSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void setIdFilter(PokemonIdFilter filter) {
    state = state.copyWith(idFilter: filter);
  }

  void selectPokemon(Pokemon pokemon) {
    state = state.copyWith(selectedPokemon: pokemon);
  }

  void selectPreviousPokemon() {
    if (state.selectedPokemon == null || state.allPokemon.isEmpty) return;
    final currentIndex = state.allPokemon.indexWhere(
      (p) => p.id == state.selectedPokemon!.id,
    );
    if (currentIndex > 0) {
      state = state.copyWith(
        selectedPokemon: state.allPokemon[currentIndex - 1],
      );
    } else {
      state = state.copyWith(selectedPokemon: state.allPokemon.last);
    }
  }

  void selectNextPokemon() {
    if (state.selectedPokemon == null || state.allPokemon.isEmpty) return;
    final currentIndex = state.allPokemon.indexWhere(
      (p) => p.id == state.selectedPokemon!.id,
    );
    if (currentIndex != -1 && currentIndex < state.allPokemon.length - 1) {
      state = state.copyWith(
        selectedPokemon: state.allPokemon[currentIndex + 1],
      );
    } else {
      state = state.copyWith(selectedPokemon: state.allPokemon.first);
    }
  }

  void clearSelectedPokemon() {
    state = state.copyWith(clearSelectedPokemon: true);
  }
}

final pokemonProvider = NotifierProvider<PokemonNotifier, PokemonState>(
  () => PokemonNotifier(),
);
