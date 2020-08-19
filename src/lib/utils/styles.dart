import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';

class AppStyles {
  // Text style for numbers of mnemonic
  static TextStyle textStyleNumbersOfMnemonic(BuildContext context) {
    return TextStyle(
      fontSize: AppFontSizes.smallText(context),
      color: KiraColors.orange3,
      fontFamily: 'OverpassMono',
      fontWeight: FontWeight.w300,
    );
  }

  // Text style for mnemonic
  static TextStyle textStyleMnemonic(BuildContext context) {
    return TextStyle(
      fontSize: AppFontSizes.smallText(context),
      color: KiraColors.purple2,
      fontFamily: 'OverpassMono',
      fontWeight: FontWeight.w300,
    );
  }

  // Text style for mnemonic success
  static TextStyle textStyleMnemonicSuccess(BuildContext context) {
    return TextStyle(
      fontSize: AppFontSizes.smallText(context),
      color: KiraColors.kYellowColor,
      fontFamily: 'OverpassMono',
      fontWeight: FontWeight.w300,
    );
  }
}

class AppFontSizes {
  static const smallest = 14.0;
  static const small = 16.0;
  static const medium = 18.0;
  static const _large = 22.0;
  static const larger = 26.0;
  static const _largest = 30.0;
  static const largestc = 30.0;
  static const _sslarge = 20.0;
  static const _sslargest = 24.0;

  static double largest(context) {
    if (smallScreen(context)) {
      return _sslargest;
    }
    return _largest;
  }

  static double large(context) {
    if (smallScreen(context)) {
      return _sslarge;
    }
    return _large;
  }

  static double smallText(context) {
    if (smallScreen(context)) {
      return smallest;
    }
    return small;
  }
}

bool smallScreen(BuildContext context) {
  if (MediaQuery.of(context).size.width < 1300)
    return true;
  else
    return false;
}
