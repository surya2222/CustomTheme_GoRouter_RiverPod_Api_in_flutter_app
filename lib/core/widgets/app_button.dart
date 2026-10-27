import 'package:flutter/material.dart';

// Flutter के UI components जैसे StatelessWidget, FilledButton,
// Icon, Text और CircularProgressIndicator उपलब्ध कराता है।

// AppButton एक custom और reusable button widget है।
// StatelessWidget का उपयोग इसलिए किया गया है क्योंकि यह widget
// अपनी loading state खुद manage नहीं करता; state बाहर से मिलती है।
class AppButton extends StatelessWidget {
  // Constructor: AppButton बनाते समय label और onPressed देना जरूरी है।
  //
  // required: ये parameters देना अनिवार्य है।
  // this.icon: optional icon।
  // this.isLoading = false: default में loading बंद रहती है।
  // super.key: widget की पहचान के लिए Key parent class को देता है।
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  // Button पर दिखाई देने वाला text।
  // उदाहरण: 'Refresh Data', 'Submit' या 'Login'।
  final String label;

  // Button दबाने पर execute होने वाला callback function।
  //
  // VoidCallback का अर्थ है ऐसा function जो कोई parameter नहीं लेता
  // और कोई value return नहीं करता।
  //
  // '?' का अर्थ है कि यह callback null भी हो सकता है।
  // null होने पर Flutter button को disabled कर सकता है।
  final VoidCallback? onPressed;

  // Button में दिखाने के लिए optional icon।
  // IconData? का अर्थ है कि icon उपलब्ध भी हो सकता है और null भी।
  final IconData? icon;

  // यह बताता है कि button का action अभी चल रहा है या नहीं।
  // true होने पर loading indicator दिखेगा और button disabled होगा।
  final bool isLoading;

  // build() method button का UI बनाता है।
  @override
  Widget build(BuildContext context) {
    // FilledButton.icon एक Material Design button है
    // जिसमें icon और label दोनों दिखाए जा सकते हैं।
    return FilledButton.icon(
      // Ternary operator (? :) से button की enabled state तय होती है।
      //
      // isLoading true है, तो onPressed = null:
      // button disabled हो जाएगा।
      //
      // isLoading false है, तो दिया गया onPressed callback इस्तेमाल होगा।
      onPressed: isLoading ? null : onPressed,

      // Loading के समय CircularProgressIndicator दिखाएँ।
      // अन्यथा दिए गए icon या default refresh icon को दिखाएँ।
      icon: isLoading
          ? const SizedBox.square(
              // Loading indicator की width और height 16 pixels।
              dimension: 16,

              // छोटा circular loading indicator।
              child: CircularProgressIndicator(
                // Indicator की stroke की मोटाई 2 pixels।
                strokeWidth: 2,
              ),
            )
          // यदि icon दिया गया है, तो वही इस्तेमाल होगा।
          // यदि icon null है, तो default refresh icon दिखेगा।
          : Icon(icon ?? Icons.refresh_rounded, size: 18),

      // Button पर label text दिखाता है।
      label: Text(label),
    );
  }
}
