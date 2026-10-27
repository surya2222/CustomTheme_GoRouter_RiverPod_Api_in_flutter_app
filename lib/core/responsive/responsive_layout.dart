import 'package:flutter/material.dart';
// Flutter के Widget, BuildContext, MediaQuery, LayoutBuilder
// और अन्य UI components का उपयोग करने के लिए।

import 'package:learn_flutter_api/app/theme/design_tokens.dart';

// App के centralized breakpoints प्राप्त करने के लिए।
// इससे responsive layout की values एक ही जगह manage होती हैं।

// enum एक निश्चित set of values define करता है।
// यहाँ screen के तीन संभावित आकार निर्धारित किए गए हैं।
enum ScreenSize {
  mobile, // Mobile screen के लिए।
  tablet, // Tablet screen के लिए।
  desktop, // Desktop या बड़ी screen के लिए।
}

// StatelessWidget का उपयोग क्योंकि यह widget अपनी internal state
// स्वयं manage नहीं करता। Screen size के आधार पर UI बनाने में मदद करता है।
class ResponsiveLayout extends StatelessWidget {
  // Constructor में builder function अनिवार्य है।
  // required का अर्थ है कि object बनाते समय builder देना जरूरी है।
  // super.key, Widget की पहचान के लिए Key को parent class तक भेजता है।
  const ResponsiveLayout({required this.builder, super.key});

  // यह callback function parent widget से UI बनाने का तरीका प्राप्त करता है।
  //
  // BuildContext: Flutter widget tree की जानकारी देता है।
  // ScreenSize: बताता है कि वर्तमान layout mobile, tablet या desktop है।
  // Widget: callback से बनने वाला UI लौटाता है।
  final Widget Function(BuildContext context, ScreenSize size) builder;

  // static method को class के नाम से call किया जा सकता है।
  // यह screen की width लेकर उचित ScreenSize return करता है।
  static ScreenSize sizeFor(double width) {
    // यदि width 600 से कम है, तो Mobile layout चुना जाएगा।
    // Breakpoint DesignTokens से लिया गया है।
    if (width < DesignTokens.mobileBreakpoint) {
      return ScreenSize.mobile;
    }

    // यदि width 600 या उससे अधिक लेकिन 1024 से कम है,
    // तो Tablet layout चुना जाएगा।
    if (width < DesignTokens.tabletBreakpoint) {
      return ScreenSize.tablet;
    }

    // यदि width 1024 या उससे अधिक है,
    // तो Desktop layout चुना जाएगा।
    return ScreenSize.desktop;
  }

  // build() method widget का UI बनाता है।
  @override
  Widget build(BuildContext context) {
    // MediaQuery से उपलब्ध screen की width प्राप्त करते हैं।
    // यह device/window की पूरी available width बताती है।
    //
    // इसे fallback के रूप में उपयोग करेंगे, यदि LayoutBuilder की
    // constraints में bounded width उपलब्ध नहीं है।
    final mediaWidth = MediaQuery.sizeOf(context).width;

    // LayoutBuilder अपने parent से मिलने वाली layout constraints देता है।
    // इससे पता चलता है कि इस widget के लिए कितनी width उपलब्ध है।
    return LayoutBuilder(
      builder: (context, constraints) {
        // hasBoundedWidth जाँचता है कि maximum width सीमित है या नहीं।
        //
        // यदि true है, तो parent द्वारा दी गई maxWidth इस्तेमाल होगी।
        // यदि false है, तो MediaQuery से मिली screen width इस्तेमाल होगी।
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : mediaWidth;

        // वास्तविक उपलब्ध width से screen size निर्धारित करते हैं।
        // फिर context और निर्धारित ScreenSize को builder callback में भेजते हैं।
        //
        // Parent widget इसी size के आधार पर अलग-अलग UI बना सकता है।
        return builder(context, sizeFor(width));
      },
    );
  }
}
