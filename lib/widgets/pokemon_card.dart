import 'package:flutter/material.dart';
import '../models/pokemon.dart';

/// Pokédex specimen card displaying ID badge, high-res artwork, and name
/// over a futuristic Pokédex digital screen bezel.
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF263238), // Dark tech console plate
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF37474F),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 3),
            blurRadius: 4,
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
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                // Pokeball watermark background
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PokeballWatermarkPainter(),
                  ),
                ),

                // Card contents
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top: Monospace Digital ID Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Small indicator light
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00E676),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withAlpha(180),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E272C),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            pokemon.formattedId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF80DEEA), // Digital cyan readout
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Middle: Official Artwork inside LCD Screen viewport
                    Expanded(
                      child: Center(
                        child: Hero(
                          tag: 'pokemon-image-${pokemon.id}',
                          child: pokemon.imageUrl.isNotEmpty
                              ? Image.network(
                                  pokemon.imageUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.cyanAccent,
                                          value: loadingProgress
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

                    const SizedBox(height: 6),

                    // Bottom: Pokémon Name Plate
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2328),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pokemon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
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

/// Draws an understated Pokeball watermark shape inside the card
class _PokeballWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.35;

    // Outer Circle
    canvas.drawCircle(center, radius, paint);

    // Horizontal Center Line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // Inner Button Ring
    final innerPaint = Paint()
      ..color = Colors.white.withAlpha(12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius * 0.35, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
