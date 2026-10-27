import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import 'nickname_dialog.dart';
import 'pokemon_type_filter.dart';

class PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;

  const PokemonCard({super.key, required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokemonProvider);
    final isFavorite = state.isFavorite(pokemon.id);
    final nickname = state.getNickname(pokemon.id);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFavorite
              ? const Color(0xFFFF1744).withAlpha(160)
              : const Color(0xFF37474F),
          width: isFavorite ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isFavorite
                ? const Color(0xFFFF1744).withAlpha(40)
                : Colors.black38,
            offset: const Offset(0, 3),
            blurRadius: isFavorite ? 8 : 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: Colors.redAccent.withAlpha(50),
          highlightColor: Colors.white10,
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Stack(
              children: [
                // Pokeball watermark background
                Positioned.fill(
                  child: CustomPaint(painter: _PokeballWatermarkPainter()),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              ref
                                  .read(pokemonProvider.notifier)
                                  .toggleFavorite(pokemon.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: AnimatedScale(
                                scale: isFavorite ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 19,
                                  color: isFavorite
                                      ? const Color(0xFFFF1744)
                                      : Colors.white60,
                                  shadows: isFavorite
                                      ? const [
                                          Shadow(
                                            color: Color(0xFFFF1744),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ID Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E272C),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Text(
                            pokemon.formattedId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF80DEEA),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Expanded(
                      child: Center(
                        child: Hero(
                          tag: 'pokemon-image-${pokemon.id}',
                          child: pokemon.imageUrl.isNotEmpty
                              ? Image.network(
                                  pokemon.imageUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.cyanAccent,
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image_rounded,
                                      size: 40,
                                      color: Colors.white30,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 40,
                                  color: Colors.white30,
                                ),
                        ),
                      ),
                    ),

                    if (pokemon.types.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          children: pokemon.types.map((type) {
                            final color = PokemonTypeColors.getColor(type);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: color.withAlpha(55),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: color.withAlpha(140),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2328),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: nickname != null
                              ? Colors.amberAccent.withAlpha(120)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (nickname != null) ...[
                                  Text(
                                    '"$nickname"',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '(${pokemon.displayName})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    pokemon.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              NicknameDialog.show(context, pokemon);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 13,
                                color: nickname != null
                                    ? Colors.amberAccent
                                    : Colors.white38,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PokeballWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width * 0.5, size.height * 0.45);
    final radius = size.width * 0.35;

    canvas.drawCircle(center, radius, paint);

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    final innerPaint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius * 0.35, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
