import 'package:flutter/material.dart';
// Flutter के UI widgets जैसे Center, Column, Icon, Text,
// ConstrainedBox और Theme का उपयोग करने के लिए।

import 'package:learn_flutter_api/core/widgets/app_button.dart';
// App का reusable custom button import करता है।

import 'package:learn_flutter_api/core/widgets/app_card.dart';
// Common styling और padding वाला reusable Card import करता है।

import 'package:learn_flutter_api/core/widgets/app_status_indicator.dart';

// Online/Offline status दिखाने वाला custom widget import करता है。

// API error या data loading failure दिखाने वाला reusable widget।
class AppErrorView extends StatelessWidget {
  // Constructor में error message और retry callback देना जरूरी है।
  // super.key, widget की Key को parent class तक पहुँचाता है।
  const AppErrorView({required this.message, required this.onRetry, super.key});

  // API से प्राप्त error या user को दिखाने वाला message।
  final String message;

  // Retry button दबाने पर चलने वाला function।
  // VoidCallback का अर्थ है बिना parameters और return value वाला function।
  final VoidCallback onRetry;

  // UI बनाने वाला method।
  @override
  Widget build(BuildContext context) => Center(
    // उपलब्ध जगह में error card को center में रखता है।
    child: AppCard(
      // Reusable Card के अंदर content की maximum width सीमित करता है।
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),

        // Column बच्चों को vertical यानी ऊपर से नीचे व्यवस्थित करता है।
        child: Column(
          // Column अपने children की जरूरत के अनुसार ही height लेता है।
          // इससे Column उपलब्ध पूरी height लेने की कोशिश नहीं करता।
          mainAxisSize: MainAxisSize.min,

          children: [
            // Cloud connection failure को दर्शाने वाला icon।
            Icon(
              Icons.cloud_off_rounded,

              // Icon का size 40 logical pixels।
              size: 40,

              // Error color Theme से लिया जाता है।
              // इससे Light/Dark Theme के अनुसार रंग बदल सकता है।
              color: Theme.of(context).colorScheme.error,
            ),

            // Icon और अगले widget के बीच 14 pixels की जगह।
            const SizedBox(height: 14),

            // Error का मुख्य heading।
            Text(
              'Could not load candle',

              // Theme का titleMedium text style इस्तेमाल करता है।
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // Heading और status indicator के बीच 8 pixels की जगह।
            const SizedBox(height: 8),

            // Offline status दिखाने वाला custom widget।
            const AppStatusIndicator(isOnline: false),

            // Status indicator और message के बीच 8 pixels की जगह।
            const SizedBox(height: 8),

            // Parent से मिला वास्तविक error message दिखाता है।
            // Text को horizontal center में align करता है।
            Text(message, textAlign: TextAlign.center),

            // Message और retry button के बीच 20 pixels की जगह।
            const SizedBox(height: 20),

            // Reusable button।
            // दबाने पर parent से मिला onRetry callback execute होगा।
            AppButton(label: 'Try again', onPressed: onRetry),
          ],
        ),
      ),
    ),
  );
}
