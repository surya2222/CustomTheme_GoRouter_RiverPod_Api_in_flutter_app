import 'package:flutter/material.dart';

// Flutter के UI widgets, styling और accessibility features के लिए।

// API की online/offline स्थिति दिखाने वाला reusable widget।
class AppStatusIndicator extends StatelessWidget {
  // Constructor में isOnline देना जरूरी है।
  // super.key widget की पहचान के लिए Key parent class को देता है।
  const AppStatusIndicator({required this.isOnline, super.key});

  // true = API online
  // false = API offline
  final bool isOnline;

  // Widget का UI बनाने वाला method।
  @override
  Widget build(BuildContext context) {
    // Ternary operator से status के अनुसार रंग चुनते हैं।
    // Online होने पर हरा, offline होने पर लाल।
    final color = isOnline ? const Color(0xFF16A673) : const Color(0xFFE05260);

    // Semantics accessibility tools को widget का अर्थ बताता है।
    // Screen reader को API online या API offline पढ़ने में मदद मिलती है।
    return Semantics(
      label: isOnline ? 'API online' : 'API offline',

      // Status badge का background, padding और content।
      child: Container(
        // Content के चारों तरफ अंदर की जगह।
        // Horizontal: 11 pixels, Vertical: 7 pixels।
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),

        // Container की background styling।
        decoration: BoxDecoration(
          // चुने गए रंग का 10% opacity वाला background।
          // withValues(alpha: 0.10) background को हल्का बनाता है।
          color: color.withValues(alpha: 0.10),

          // Badge के corners को 20 pixels तक गोल करता है।
          borderRadius: BorderRadius.circular(20),
        ),

        // Dot और text को एक ही horizontal line में रखता है।
        child: Row(
          // Row केवल अपने children की जरूरत के अनुसार width लेती है।
          mainAxisSize: MainAxisSize.min,

          children: [
            // छोटा गोल status dot।
            Container(
              width: 7,
              height: 7,

              // Dot का रंग status के अनुसार हरा या लाल होता है।
              decoration: BoxDecoration(
                color: color,

                // Container को circle बनाता है।
                shape: BoxShape.circle,
              ),
            ),

            // Dot और text के बीच 7 pixels की horizontal दूरी।
            const SizedBox(width: 7),

            // Status के अनुसार text दिखाता है।
            Text(
              isOnline ? 'API online' : 'API offline',

              // Text की styling।
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
