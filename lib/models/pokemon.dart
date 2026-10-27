class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
  });

  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  factory Pokemon.fromListJson(Map<String, dynamic> json, {List<String>? types}) {
    final name = json['name'] as String? ?? 'Unknown';
    final url = json['url'] as String? ?? '';

    final segments = url
        .split('/')
        .where((segment) => segment.trim().isNotEmpty)
        .toList();
    final parsedId = segments.isNotEmpty ? int.tryParse(segments.last) ?? 0 : 0;

    final imageUrl = parsedId > 0
        ? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$parsedId.png'
        : '';

    return Pokemon(
      id: parsedId,
      name: name,
      imageUrl: imageUrl,
      types: types ?? const [],
    );
  }

  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final name = json['name'] as String? ?? 'Unknown';

    String imageUrl = '';
    final sprites = json['sprites'] as Map<String, dynamic>?;
    if (sprites != null) {
      final other = sprites['other'] as Map<String, dynamic>?;
      final officialArtwork =
          other?['official-artwork'] as Map<String, dynamic>?;
      imageUrl = officialArtwork?['front_default'] as String? ?? '';
      if (imageUrl.isEmpty) {
        imageUrl = sprites['front_default'] as String? ?? '';
      }
    }
    if (imageUrl.isEmpty && id > 0) {
      imageUrl =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
    }

    final rawTypes = json['types'] as List<dynamic>? ?? [];
    final types = rawTypes
        .map((t) => (t['type']?['name'] as String? ?? '').toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList();

    return Pokemon(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: types,
    );
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('types')) {
      return Pokemon.fromDetailJson(json);
    }
    return Pokemon.fromListJson(json);
  }

  Pokemon copyWith({
    int? id,
    String? name,
    String? imageUrl,
    List<String>? types,
  }) {
    return Pokemon(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      types: types ?? this.types,
    );
  }
}
