import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_adaptive_ui/layouts/desktop_layout.dart';
import 'package:responsive_adaptive_ui/layouts/mobile_layout.dart';
import 'package:responsive_adaptive_ui/layouts/tablet_layout.dart';
import 'package:responsive_adaptive_ui/main.dart';
import 'package:responsive_adaptive_ui/models/platform_mode.dart';
import 'package:responsive_adaptive_ui/widgets/adaptive_card.dart';
import 'package:responsive_adaptive_ui/widgets/adaptive_nav_drawer.dart';

void main() {
  group('Responsive Layout Tests', () {
    testWidgets('Renders MobileLayout with 2x2 grid and list when width < 600', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ResponsiveAdaptiveApp());
      await tester.pumpAndSettle();

      expect(find.byType(MobileLayout), findsOneWidget);
      expect(find.byType(TabletLayout), findsNothing);
      expect(find.byType(DesktopLayout), findsNothing);
      expect(find.text('responsivedashboard'), findsOneWidget);

      // Verify grid and cards
      final gridFinder = find.descendant(
        of: find.byType(MobileLayout),
        matching: find.byType(GridView),
      );
      expect(gridFinder, findsOneWidget);

      final cardsFinder = find.descendant(
        of: find.byType(MobileLayout),
        matching: find.byType(AdaptiveCard),
      );
      // 4 grid cards + 5 list cards = 9
      expect(cardsFinder, findsNWidgets(9));
    });

    testWidgets('Renders TabletLayout with 1x4 grid when width is between 600 and 1050', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ResponsiveAdaptiveApp());
      await tester.pumpAndSettle();

      expect(find.byType(TabletLayout), findsOneWidget);
      expect(find.byType(MobileLayout), findsNothing);
      expect(find.byType(DesktopLayout), findsNothing);

      final cardsFinder = find.descendant(
        of: find.byType(TabletLayout),
        matching: find.byType(AdaptiveCard),
      );
      // 4 top cards + 5 list cards = 9
      expect(cardsFinder, findsNWidgets(9));
    });

    testWidgets('Renders DesktopLayout with 3-column split view when width >= 1050', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ResponsiveAdaptiveApp());
      await tester.pumpAndSettle();

      expect(find.byType(DesktopLayout), findsOneWidget);
      expect(find.byType(MobileLayout), findsNothing);
      expect(find.byType(TabletLayout), findsNothing);

      // Column 1: Permanent sidebar
      expect(find.byType(AdaptiveNavDrawer), findsOneWidget);
      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('LOGOUT'), findsOneWidget);

      // Column 2 & 3: Total cards (4 center top + 5 center list + 2 right cards = 11 cards)
      final allCards = find.descendant(
        of: find.byType(DesktopLayout),
        matching: find.byType(AdaptiveCard),
      );
      expect(allCards, findsNWidgets(11));
    });
  });

  group('Adaptive Platform Tests', () {
    testWidgets('Renders Cupertino icons and dialog in Cupertino mode', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ResponsiveAdaptiveApp(initialPlatformMode: PlatformMode.cupertino),
      );
      await tester.pumpAndSettle();

      // In Cupertino mode, icons should be CupertinoIcons
      expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.house_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.gear_alt_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.info_circle_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.square_arrow_right), findsOneWidget);

      // Tap Logout to test CupertinoAlertDialog
      await tester.tap(find.text('LOGOUT'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Confirm Logout'), findsOneWidget);
    });

    testWidgets('Renders Material icons and dialog in Material mode', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ResponsiveAdaptiveApp(initialPlatformMode: PlatformMode.material),
      );
      await tester.pumpAndSettle();

      // In Material mode, icons should be Material icons
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);

      // Tap Logout to test AlertDialog
      await tester.tap(find.text('LOGOUT'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Confirm Logout'), findsOneWidget);
    });

    testWidgets('Drawer opens and handles Settings and About dialogs', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ResponsiveAdaptiveApp());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byTooltip('Open Navigation Drawer'));
      await tester.pumpAndSettle();

      // Tap Settings
      await tester.tap(find.text('SETTINGS'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      // Dismiss dialog and settle
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Open drawer again and tap About
      await tester.tap(find.byTooltip('Open Navigation Drawer'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ABOUT'));
      await tester.pumpAndSettle();
      expect(find.text('About Responsive Dashboard'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });
}
