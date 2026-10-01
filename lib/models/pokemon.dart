class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  const Pokemon({required this.id, required this.name, required this.imageUrl});

  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) {
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

    return Pokemon(id: parsedId, name: name, imageUrl: imageUrl);
  }
}
