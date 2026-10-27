import 'package:flutter/material.dart';
// Flutter के UI widgets जैसे Center, Padding, Column,
// CircularProgressIndicator और Text उपलब्ध कराता है।

import 'package:learn_flutter_api/app/theme/design_tokens.dart';
// App में consistent spacing रखने के लिए centralized design values import करता है।

import 'package:learn_flutter_api/core/widgets/app_card.dart';

// Reusable AppCard widget import करता है, ताकि loading UI भी
// app की common card styling और padding का उपयोग कर सके।

// API data load होने के दौरान दिखाया जाने वाला reusable widget।
class AppLoading extends StatelessWidget {
  // Constructor: इस widget को कोई अतिरिक्त parameter नहीं चाहिए।
  // super.key, widget की पहचान के लिए Key parent class तक पहुँचाता है।
  const AppLoading({super.key});

  // build() method widget का UI बनाता है।
  @override
  Widget build(BuildContext context) => const Center(
    // Loading card को उपलब्ध जगह के बीच में रखता है।
    child: AppCard(
      // Card के अंदर अतिरिक्त Padding लगाता है।
      child: Padding(
        // Horizontal padding: बाएँ और दाएँ space6।
        // Vertical padding: ऊपर और नीचे space5।
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.space6,
          vertical: DesignTokens.space5,
        ),

        // Column बच्चों को ऊपर से नीचे व्यवस्थित करता है।
        child: Column(
          // Column अपनी content की जरूरत के अनुसार height लेता है।
          mainAxisSize: MainAxisSize.min,

          // Column के अंदर दिखने वाले widgets।
          children: [
            // गोल घूमने वाला loading indicator दिखाता है।
            // यह user को बताता है कि कोई काम चल रहा है।
            CircularProgressIndicator(),

            // Spinner और message के बीच निर्धारित vertical space।
            SizedBox(height: DesignTokens.space4),

            // User को बताता है कि app stock API से connect कर रही है।
            Text('Connecting to stock API...'),
          ],
        ),
      ),
    ),
  );
}
