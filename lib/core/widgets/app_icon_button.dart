import 'package:flutter/material.dart';

// Flutter के Material Design widgets उपलब्ध कराता है।
// इसमें IconButton, Icon, Tooltip और अन्य UI components शामिल हैं।

// Reusable Icon Button बनाने के लिए custom widget।
class AppIconButton extends StatelessWidget {
  // Constructor: icon, tooltip और onPressed देना जरूरी है।
  // super.key, widget की Key को parent class तक पहुँचाता है।
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  // Button पर कौन-सा icon दिखाना है।
  // IconData में Icons.refresh, Icons.settings आदि values आती हैं।
  final IconData icon;

  // Button पर hover करने या उसे accessibility के माध्यम से पहचानने
  // के लिए descriptive text।
  final String tooltip;

  // Button दबाने पर execute होने वाला callback।
  // VoidCallback का अर्थ है ऐसा function जो कोई argument नहीं लेता
  // और कोई value return नहीं करता।
  //
  // '?' का मतलब है कि callback null भी हो सकता है।
  // null होने पर IconButton disabled हो जाता है।
  final VoidCallback? onPressed;

  // Widget का UI बनाने वाला method।
  @override
  Widget build(BuildContext context) =>
      // Flutter का built-in IconButton इस्तेमाल करता है।
      // Arrow syntax (=>) एक expression को सीधे return करता है।
      IconButton(
        // Button दबाने पर यह callback execute होगा।
        // null होने पर button disabled रहेगा।
        onPressed: onPressed,

        // Icon का उद्देश्य बताने वाला tooltip।
        // उदाहरण: 'Refresh chart' या 'Open settings'।
        tooltip: tooltip,

        // IconData से वास्तविक icon widget बनाता है।
        icon: Icon(icon),
      );
}
