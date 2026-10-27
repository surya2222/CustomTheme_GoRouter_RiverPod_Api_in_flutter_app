import 'package:flutter/material.dart';
// Flutter के UI components जैसे Scaffold, AppBar, Row,
// NavigationBar, NavigationRail और MediaQuery उपलब्ध कराता है।

import 'package:go_router/go_router.dart';
// GoRouter navigation के लिए। context.go() से दूसरी route पर जा सकते हैं।

import 'package:learn_flutter_api/app/theme/design_tokens.dart';

// App के centralized breakpoints, spacing और maximum content width के लिए।

// Reusable page layout जो app की सभी screens में इस्तेमाल हो सकता है।
class AppScaffold extends StatelessWidget {
  // Constructor में title, route और child देना जरूरी है।
  // actions optional हैं और default में खाली list है।
  const AppScaffold({
    required this.title,
    required this.route,
    required this.child,
    this.actions = const [],
    super.key,
  });

  // AppBar में दिखाई देने वाला page title।
  final String title;

  // वर्तमान screen का route, जैसे '/', '/candle' या '/settings'।
  // इससे navigation में selected item निर्धारित होता है।
  final String route;

  // वर्तमान page का मुख्य UI।
  // उदाहरण: Dashboard content, Candle chart या Settings form।
  final Widget child;

  // AppBar के दाईं तरफ दिखने वाले अतिरिक्त widgets।
  // उदाहरण: Refresh button या अन्य action icons।
  final List<Widget> actions;

  // Navigation के सभी destinations की static, unmodifiable list।
  // हर destination में label, route और icon रखा गया है।
  static const _destinations = [
    _Destination('Overview', '/', Icons.space_dashboard_outlined),
    _Destination('Candle', '/candle', Icons.candlestick_chart_outlined),
    _Destination('Settings', '/settings', Icons.tune_rounded),
  ];

  // Getter: वर्तमान route के अनुसार selected navigation index देता है।
  // इसे method की तरह () लगाकर call करने की जरूरत नहीं है।
  int get _selectedIndex {
    // वह index खोजता है जिसका route, वर्तमान route के बराबर है।
    final index = _destinations.indexWhere(
      (destination) => destination.route == route,
    );

    // यदि route नहीं मिलता, तो default रूप से index 0 लौटाता है।
    // अन्यथा मिला हुआ index लौटाता है।
    return index < 0 ? 0 : index;
  }

  // Navigation item चुने जाने पर यह method चलता है।
  void _navigate(BuildContext context, int index) {
    // चुने गए index से संबंधित destination प्राप्त करता है।
    final destination = _destinations[index];

    // यदि destination वर्तमान route से अलग है,
    // तभी GoRouter के माध्यम से navigation करता है।
    if (route != destination.route) {
      context.go(destination.route);
    }
  }

  // पूरे page layout का UI बनाता है।
  @override
  Widget build(BuildContext context) {
    // वर्तमान app window की width प्राप्त करता है।
    final width = MediaQuery.sizeOf(context).width;

    // Breakpoint के बराबर या उससे बड़ी width पर
    // wide layout इस्तेमाल किया जाएगा।
    final isWide = width >= DesignTokens.mobileBreakpoint;

    // Main content की maximum width सीमित करता है।
    // इससे बड़ी screen पर content अनावश्यक रूप से चौड़ा नहीं होगा।
    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: DesignTokens.contentMaxWidth),
      child: child,
    );

    // Scaffold page का मुख्य Material Design structure है।
    // इसमें AppBar, body और bottomNavigationBar जैसे sections होते हैं।
    return Scaffold(
      // ─────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────

      appBar: AppBar(
        // Title में icon और text को horizontal direction में रखता है।
        title: Row(
          children: [
            // Candle chart का icon।
            Icon(
              Icons.candlestick_chart_rounded,

              // Icon का रंग current Theme के primary color से आता है।
              color: Theme.of(context).colorScheme.primary,
            ),

            // Icon और title के बीच 10 logical pixels की जगह।
            const SizedBox(width: 10),

            // Flexible, title को उपलब्ध horizontal जगह में रखता है।
            Flexible(
              child: Text(
                title,

                // Title को अधिकतम एक line में रखता है।
                maxLines: 1,

                // जगह कम होने पर text के अंत में ... दिखाता है।
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Caller द्वारा दिए गए action widgets AppBar में दिखाता है।
        actions: actions,
      ),

      // ─────────────────────────────────────
      // BODY
      // ─────────────────────────────────────
      body: SafeArea(
        // AppBar के ठीक नीचे अतिरिक्त top safe padding नहीं जोड़ता।
        // अन्य लागू safe-area padding बनी रहती है।
        top: false,

        // Wide screen और narrow screen के लिए अलग layout।
        child: isWide
            // ───────────────────────────────
            // TABLET / DESKTOP LAYOUT
            // ───────────────────────────────
            ? Row(
                children: [
                  // बड़ी screen पर navigation बाईं तरफ दिखता है।
                  NavigationRail(
                    selectedIndex: _selectedIndex,

                    // Item select होने पर संबंधित route पर navigate करता है।
                    onDestinationSelected: (index) => _navigate(context, index),

                    // हर destination को NavigationRailDestination में बदलता है।
                    destinations: _destinations
                        .map(
                          (destination) => NavigationRailDestination(
                            icon: Icon(destination.icon),
                            label: Text(destination.label),
                          ),
                        )
                        .toList(),
                  ),

                  // Navigation और content के बीच vertical divider।
                  const VerticalDivider(width: 1),

                  // बची हुई horizontal जगह main content को देता है।
                  Expanded(
                    child: Center(
                      // Desktop पर content के चारों तरफ 24 pixels की padding।
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.space5),

                        // Maximum width वाले main content को दिखाता है।
                        child: content,
                      ),
                    ),
                  ),
                ],
              )
            // ───────────────────────────────
            // MOBILE LAYOUT
            // ───────────────────────────────
            : Padding(
                // Mobile पर content के चारों तरफ 16 pixels की padding।
                padding: const EdgeInsets.all(DesignTokens.space4),

                // वर्तमान screen का मुख्य UI।
                child: content,
              ),
      ),

      // ─────────────────────────────────────
      // BOTTOM NAVIGATION
      // ─────────────────────────────────────

      // Wide screen पर नीचे navigation नहीं दिखेगा।
      // Mobile पर Bottom Navigation Bar दिखाई देगा।
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              // वर्तमान route का selected navigation item।
              selectedIndex: _selectedIndex,

              // User item चुने तो संबंधित route पर जाएँ।
              onDestinationSelected: (index) => _navigate(context, index),

              // हर destination को Bottom Navigation item में बदलता है।
              destinations: _destinations
                  .map(
                    (destination) => NavigationDestination(
                      icon: Icon(destination.icon),
                      label: destination.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

// Navigation के एक item का data model।
// यह private class है क्योंकि इसके नाम की शुरुआत "_" से होती है।
class _Destination {
  // Constructor में label, route और icon प्राप्त होते हैं।
  const _Destination(this.label, this.route, this.icon);

  // Navigation में दिखने वाला text।
  final String label;

  // Navigation item से जुड़ा route path।
  final String route;

  // Navigation item का icon।
  final IconData icon;
}
