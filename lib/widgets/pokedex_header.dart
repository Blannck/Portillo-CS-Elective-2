import 'package:flutter/material.dart';

/// The iconic Pokédex top bar featuring the official Pokédex / Pokéball logo emblem on the top left,
/// the red, yellow, and green indicator LEDs, the POKÉDEX brand plate, and a reload button.
class PokedexHeader extends StatelessWidget {
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  const PokedexHeader({
    super.key,
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFDC0A2D), // Classic Pokédex Crimson
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Authentic Pokédex / Pokéball Logo Emblem on the Top Left
          const PokedexLogo(size: 48),

          const SizedBox(width: 12),

          // Three Small LED Indicator Lights (Red, Yellow, Green)
          Row(
            children: [
              _buildSmallLed(
                color: const Color(0xFFFF1744),
                highlight: const Color(0xFFFF8A80),
              ),
              const SizedBox(width: 8),
              _buildSmallLed(
                color: const Color(0xFFFFD600),
                highlight: const Color(0xFFFFFF8D),
              ),
              const SizedBox(width: 8),
              _buildSmallLed(
                color: const Color(0xFF00E676),
                highlight: const Color(0xFFB9F6CA),
              ),
            ],
          ),

          const Spacer(),

          // Pokédex Title Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8E061D),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.catching_pokemon,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'POKÉDEX',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Refresh Button
          IconButton(
            icon: isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sync_rounded, color: Colors.white),
            tooltip: 'Reload Data',
            onPressed: isRefreshing ? null : onRefresh,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLed({required Color color, required Color highlight}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black45, width: 1.5),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: [highlight, color],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(180),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// A precision vector-composed Pokédex / Pokéball emblem with red & white hemispheres,
/// dark dividing band, glowing center button, and glossy reflection highlight.
class PokedexLogo extends StatelessWidget {
  final double size;

  const PokedexLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Upper Hemisphere (Vibrant Pokémon Red with gradient)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size * 0.5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFF385C),
                      Color(0xFFD32F2F),
                    ],
                  ),
                ),
              ),
            ),

            // Lower Hemisphere (Crisp White/Off-White)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: size * 0.5,
              child: Container(
                color: const Color(0xFFF5F5F5),
              ),
            ),

            // Center Dark Band
            Container(
              height: size * 0.16,
              color: const Color(0xFF212121),
            ),

            // Center Outer Button Rim
            Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF212121),
              ),
            ),

            // Center Inner Button with Glow
            Container(
              width: size * 0.22,
              height: size * 0.22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withAlpha(160),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),

            // Specular Gloss Highlight Reflection
            Positioned(
              top: size * 0.08,
              left: size * 0.16,
              child: Container(
                width: size * 0.25,
                height: size * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(110),
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(size * 0.12, size * 0.06),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
