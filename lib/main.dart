import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFD0D7DE),
        useMaterial3: true,
      ),
      home: const MyAppHomeScreen(),
    );
  }
}

class MyAppHomeScreen extends StatelessWidget {
  const MyAppHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5DFE8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double frameW = 454.0;
          const double frameH = 956.0;
          final double scaleX = constraints.maxWidth / (frameW + 32);
          final double scaleY = constraints.maxHeight / (frameH + 48);
          final double scale = scaleX < scaleY ? scaleX : scaleY;
          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: frameW,
                height: frameH,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: const IPhoneFrame(child: PhoneScreenContent()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class IPhoneFrame extends StatelessWidget {
  final Widget child;

  const IPhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 454,
      height: 956,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 454,
            height: 956,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1D21),
              borderRadius: BorderRadius.circular(56),
              border: Border.all(color: const Color(0xFF3B3D46), width: 2.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.38),
                  blurRadius: 40,
                  spreadRadius: 5,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Container(
                width: 430,
                height: 932,
                color: const Color(0xFFFAF9F6),
                child: Stack(
                  children: [
                    Positioned.fill(child: child),

                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IPhoneStatusBar(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            top: 130,
            child: Container(
              width: 4.5,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2D35),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 185,
            child: Container(
              width: 4.5,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2D35),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 255,
            child: Container(
              width: 4.5,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2D35),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),

          Positioned(
            right: 0,
            top: 205,
            child: Container(
              width: 4.5,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2D35),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IPhoneStatusBar extends StatelessWidget {
  const IPhoneStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      height: 54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '9:41',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),

          Container(
            width: 125,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 10),

                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1524),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1E2638),
                      width: 1.5,
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(right: 14),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C0F17),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: const [
              Icon(
                Icons.signal_cellular_4_bar_rounded,
                color: Colors.white,
                size: 15,
              ),
              SizedBox(width: 4),
              Icon(Icons.wifi_rounded, color: Colors.white, size: 15),
              SizedBox(width: 4),
              Icon(Icons.battery_full_rounded, color: Colors.white, size: 17),
            ],
          ),
        ],
      ),
    );
  }
}

class PhoneScreenContent extends StatelessWidget {
  const PhoneScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopHeaderSection(),

        const Expanded(child: OverviewSection()),

        Container(
          color: const Color(0xFFFAF9F6),
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Center(
            child: Container(
              width: 140,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TopHeaderSection extends StatelessWidget {
  const TopHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF11141A),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D0F14),
            Color(0xFF141923),
            Color(0xFF13324C),
            Color(0xFF165C8E),
            Color(0xFF389EDC),
          ],
          stops: [0.0, 0.35, 0.65, 0.85, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            right: -20,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00A2FF).withValues(alpha: 0.35),
                    const Color(0xFF0052D4).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FA3EA), Color(0xFF1E5B94)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00A2FF).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF11141A),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 38,
                      backgroundColor: Color(0xFF283244),
                      child: Text('👨🏻‍💼', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Lae Portillo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Rmcx_dn8v87d_ljh8589',
                      style: TextStyle(
                        color: Color(0xFF9EA3AE),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF9EA3AE),
                      size: 14,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'Current Balance',
                  style: TextStyle(
                    color: Color(0xFF9EA3AE),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  '\₱98,325',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF9F6),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E24),
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: 18),
          TransactionTile(
            avatarEmoji: '👩🏽‍🦱',
            avatarBgColor: Color(0xFFE8D7F0),
            title: 'Received Money',
            date: 'November 02, 2023',
            amount: '+ \₱213.00',
            time: '10:12 PM',
          ),
          SizedBox(height: 14),
          TransactionTile(
            avatarEmoji: '👨🏽',
            avatarBgColor: Color(0xFFE2E4DF),
            title: 'Received Money',
            date: 'October 29, 2023',
            amount: '+ \₱102.00',
            time: '10:12 PM',
          ),
          SizedBox(height: 14),
          TransactionTile(
            avatarEmoji: '👨🏻‍💻',
            avatarBgColor: Color(0xFFE5DDD5),
            title: 'Received Money',
            date: 'October 16, 2023',
            amount: '+ \₱300.00',
            time: '10:12 PM',
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String avatarEmoji;
  final Color avatarBgColor;
  final String title;
  final String date;
  final String amount;
  final String time;

  const TransactionTile({
    super.key,
    required this.avatarEmoji,
    required this.avatarBgColor,
    required this.title,
    required this.date,
    required this.amount,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(avatarEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E24),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8E99),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E24),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF9DA1AA),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
