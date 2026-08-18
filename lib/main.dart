import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const FruitApp());
}

class Fruit {
  const Fruit({
    required this.name,
    required this.emoji,
    required this.color,
    required this.description,
    required this.fact,
  });

  final String name;
  final String emoji;
  final Color color;
  final String description;
  final String fact;
}

const List<Fruit> fruits = [
  Fruit(
    name: 'apple',
    emoji: '🍎',
    color: Color(0xFFE53935),
    description: 'Crispy, sweet and refreshing.',
    fact: 'Apples are 25% air, which is why they float on water!',
  ),
  Fruit(
    name: 'banana',
    emoji: '🍌',
    color: Color(0xFFFDD835),
    description: 'Naturally sweet, soft and energy-packed.',
    fact: 'Bananas are technically berries, but strawberries are not!',
  ),
  Fruit(
    name: 'orange',
    emoji: '🍊',
    color: Color(0xFFFF6F00),
    description: 'Zesty, juicy and full of vitamin C.',
    fact: 'Oranges never ripen once picked from the tree.',
  ),
  Fruit(
    name: 'grape',
    emoji: '🍇',
    color: Color(0xFF7B1FA2),
    description: 'Small, sweet and loaded with antioxidants.',
    fact: 'It takes about 1,200 grapes to make one bottle of wine.',
  ),
  Fruit(
    name: 'watermelon',
    emoji: '🍉',
    color: Color(0xFF43A047),
    description: '92% water, 100% summer vibes.',
    fact: 'Watermelon is both a fruit AND a vegetable.',
  ),
  Fruit(
    name: 'strawberry',
    emoji: '🍓',
    color: Color(0xFFE91E63),
    description: 'Heart-shaped, ruby-red perfection.',
    fact: 'Strawberries are the only fruit with seeds on the outside.',
  ),
  Fruit(
    name: 'lemon',
    emoji: '🍋',
    color: Color(0xFFF9A825),
    description: 'Sour, bright and versatile in the kitchen.',
    fact: 'Lemons were once so valuable they were given as royal gifts.',
  ),
  Fruit(
    name: 'mango',
    emoji: '🥭',
    color: Color(0xFFFF8F00),
    description: 'Tropical, rich and impossibly fragrant.',
    fact: 'Mangoes are the most consumed fruit in the world.',
  ),
];

Fruit? findFruit(String name) {
  try {
    return fruits.firstWhere((f) => f.name == name.toLowerCase());
  } catch (_) {
    return null;
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FruitListPage(),

      routes: [
        GoRoute(
          path: 'fruit/:name',
          builder: (context, state) {
            final name = state.pathParameters['name']!;
            return FruitDetailPage(fruitName: name);
          },
        ),
      ],
    ),
  ],
);

class FruitApp extends StatelessWidget {
  const FruitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fruit Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      routerConfig: _router,
    );
  }
}

class FruitListPage extends StatelessWidget {
  const FruitListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Fruit Explorer'),
            centerTitle: false,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              background: _AppBarBackground(
                color: colorScheme.primaryContainer,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: fruits.length,
              itemBuilder: (context, index) {
                final fruit = fruits[index];
                return _FruitCard(fruit: fruit);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarBackground extends StatelessWidget {
  const _AppBarBackground({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -20,
          top: -10,
          child: Text('🍓🍋🥭', style: TextStyle(fontSize: 80, height: 1.2)),
        ),
        Positioned(
          right: 60,
          bottom: 10,
          child: Text('🍎🍇', style: TextStyle(fontSize: 60, height: 1.2)),
        ),
      ],
    );
  }
}

class _FruitCard extends StatelessWidget {
  const _FruitCard({required this.fruit});
  final Fruit fruit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: fruit.color.withAlpha(30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: fruit.color.withAlpha(80), width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => context.go('/fruit/${fruit.name}'),
        splashColor: fruit.color.withAlpha(60),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(fruit.emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 10),
              Text(
                fruit.name[0].toUpperCase() + fruit.name.substring(1),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: fruit.color.darken(0.2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fruit.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FruitDetailPage extends StatelessWidget {
  const FruitDetailPage({super.key, required this.fruitName});
  final String fruitName;

  @override
  Widget build(BuildContext context) {
    final fruit = findFruit(fruitName);

    if (fruit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('🤷 Fruit not found')),
      );
    }

    return Scaffold(
      backgroundColor: fruit.color.withAlpha(15),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: fruit.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                fruit.name[0].toUpperCase() + fruit.name.substring(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                ),
              ),
              background: _FruitIllustration(fruit: fruit),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: fruit.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: fruit.color.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link,
                          size: 14,
                          color: fruit.color.darken(0.1),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '/fruit/${fruit.name}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: fruit.color.darken(0.1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _InfoCard(
                    icon: Icons.info_outline,
                    color: fruit.color,
                    title: 'About',
                    content: fruit.description,
                  ),
                  const SizedBox(height: 16),

                  _InfoCard(
                    icon: Icons.lightbulb_outline,
                    color: fruit.color,
                    title: 'Fun Fact',
                    content: fruit.fact,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: fruit.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text(
                        'Back to Fruit List',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () => context.go('/'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FruitIllustration extends StatelessWidget {
  const _FruitIllustration({required this.fruit});
  final Fruit fruit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Painted background with circular blobs
        CustomPaint(painter: _BlobPainter(color: fruit.color)),

        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Text(
              fruit.emoji,
              style: const TextStyle(fontSize: 120, height: 1),
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, fruit.color.withAlpha(180)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final base = color;
    final light = Color.lerp(base, Colors.white, 0.3)!;
    final dark = Color.lerp(base, Colors.black, 0.15)!;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [light, base, dark],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final blobPaint = Paint()..color = Colors.white.withAlpha(25);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      80,
      blobPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.1),
      60,
      blobPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.8),
      100,
      blobPaint,
    );

    final sparklePaint = Paint()..color = Colors.white.withAlpha(50);
    for (final offset in [
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.15),
      Offset(size.width * 0.9, size.height * 0.5),
    ]) {
      _drawStar(canvas, offset, 12, sparklePaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final r = i.isEven ? radius : radius * 0.45;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) => old.color != color;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color.darken(0.1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _ColorBrightness on Color {
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
