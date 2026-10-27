import 'package:flutter/material.dart';
// Flutter के UI widgets जैसे Card, Padding और Widget का उपयोग करने के लिए।

import 'package:learn_flutter_api/app/theme/design_tokens.dart';

// DesignTokens से common spacing values लेने के लिए।
// इससे पूरे app में consistent spacing बनी रहती है।

// AppCard एक custom reusable widget है।
// StatelessWidget का अर्थ है कि यह widget अपनी internal state
// खुद manage नहीं करता।
class AppCard extends StatelessWidget {
  // Constructor: child देना जरूरी है।
  //
  // padding optional है। यदि caller padding नहीं देता,
  // तो DesignTokens.space5 यानी 24 logical pixels की padding होगी।
  //
  // super.key widget की पहचान के लिए Key parent class को देता है।
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(DesignTokens.space5),
    super.key,
  });

  // Card के अंदर दिखने वाला widget।
  // उदाहरण: Text, Column, Row, Chart या कोई दूसरा widget।
  final Widget child;

  // Card के content और उसकी boundary के बीच की दूरी।
  // EdgeInsetsGeometry अलग-अलग दिशाओं में padding define कर सकता है।
  final EdgeInsetsGeometry padding;

  // build() method widget का UI बनाता है।
  @override
  // Arrow syntax (=>) का उपयोग एक expression return करने के लिए किया गया है।
  Widget build(BuildContext context) => Card(
    // Card के अंदर Padding widget रखा गया है।
    child: Padding(
      // Card के अंदर content के चारों ओर निर्धारित padding लगती है।
      padding: padding,

      // Caller द्वारा दिया गया widget Card के अंदर दिखाया जाता है।
      child: child,
    ),
  );
}
