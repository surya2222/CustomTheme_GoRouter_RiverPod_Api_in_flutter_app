import 'package:flutter/material.dart';
// Flutter के UI components और Material Design widgets को import करता है।

import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod को import करता है, ताकि हम Provider से application की state पढ़ सकें।

import 'package:learn_flutter_api/app/router.dart';
// App में navigation और routing की configuration import करता है।

import 'package:learn_flutter_api/app/theme/app_theme.dart';
// Application की Light और Dark Theme की configuration import करता है।

import 'package:learn_flutter_api/providers/settings_provider.dart';

// themeModeProvider को import करता है, जो वर्तमान Theme Mode की state रखता है।
// ConsumerWidget एक ऐसा widget है जो Riverpod providers को access कर सकता है।

class StockDashboardApp extends ConsumerWidget {
  // const constructor widget को immutable बनाने में मदद करता है।
  // ConsumerWidget refer to riverpod
  // super.key, widget की पहचान के लिए Key को parent class तक पहुँचाता है।
  const StockDashboardApp({super.key});

  // build() method बताता है कि UI किस तरह बनाया जाएगा।
  // BuildContext Flutter widget tree में इस widget की location बताता है।
  // WidgetRef के माध्यम से हम Riverpod providers को read या watch कर सकते हैं।
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //ref show the provider calling
    // WidgetRef ref refer to riverpod
    // themeModeProvider की state को observe करता है।
    // जब Theme Mode बदलता है, तो यह widget दोबारा build होता है।
    // themeModeProvider refer to settings_provider.dart'

    final themeMode = ref.watch(themeModeProvider);

    // MaterialApp.router app का मुख्य configuration widget है।
    // यह Material Design, Theme और Router-based navigation को configure करता है।
    return MaterialApp.router(
      // App का नाम निर्धारित करता है।
      title: 'Candleboard',

      // Debug mode में ऊपर दिखाई देने वाला DEBUG banner छिपाता है।
      debugShowCheckedModeBanner: false,

      // App के लिए Light Theme निर्धारित करता है।
      // इसकी definition app_theme.dart में मौजूद है।
      // theme: AppTheme.light refer to app_theme.dart
      theme: AppTheme.light,

      // App के लिए Dark Theme निर्धारित करता है।
      // इसकी definition भी app_theme.dart में मौजूद है।
      // theme: AppTheme.dark refer to app_theme.dart
      darkTheme: AppTheme.dark,

      // तय करता है कि Light Theme, Dark Theme या System Theme इस्तेमाल होगी।
      // इसकी value Riverpod provider से आती है।
      themeMode: themeMode,

      // App की navigation और route configuration सेट करता है।
      // इसकी definition router.dart में मौजूद है।
      routerConfig: appRouter,

      // appRouter refer to router.dart
    );
  }
}
