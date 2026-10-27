import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_api/app/app.dart';

void main() {
  runApp(const ProviderScope(child: StockDashboardApp()));
}
