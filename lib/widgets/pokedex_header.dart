import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pokemon_provider.dart';

class PokedexHeader extends ConsumerWidget {
  const PokedexHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);
    final isRefreshing = state.isLoading;
    final favoriteCount = state.favorites.length;
    final isFavoritesExpanded = state.isFavoritesPanelExpanded;

    return Container(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 14, bottom: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFDC0A2D),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 4),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PokedexLogo(size: 44),

          const SizedBox(width: 10),

          Row(
            children: [
              _buildSmallLed(
                color: const Color(0xFFFF1744),
                highlight: const Color(0xFFFF8A80),
              ),
              const SizedBox(width: 6),
              _buildSmallLed(
                color: const Color(0xFFFFD600),
                highlight: const Color(0xFFFFFF8D),
              ),
              const SizedBox(width: 6),
              _buildSmallLed(
                color: const Color(0xFF00E676),
                highlight: const Color(0xFFB9F6CA),
              ),
            ],
          ),

          const Spacer(),

          InkWell(
            onTap: () => notifier.toggleFavoritesPanel(),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isFavoritesExpanded
                    ? const Color(0xFF8E061D)
                    : const Color(0xFF2B2D42).withAlpha(180),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFavoritesExpanded
                      ? const Color(0xFFFF5252)
                      : Colors.white24,
                  width: 1.5,
                ),
                boxShadow: isFavoritesExpanded
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF1744).withAlpha(100),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFavoritesExpanded
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: const Color(0xFFFF5252),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'FAVORITES',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1744),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$favoriteCount',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isFavoritesExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

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
            tooltip: 'Reload Pokémon List',
            onPressed: isRefreshing ? null : () => notifier.fetchPokemonList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLed({required Color color, required Color highlight}) {
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black45, width: 1.2),
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
          BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
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
                    colors: [Color(0xFFFF385C), Color(0xFFD32F2F)],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: size * 0.5,
              child: Container(color: const Color(0xFFF5F5F5)),
            ),

            Container(height: size * 0.16, color: const Color(0xFF212121)),

            Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF212121),
              ),
            ),

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
