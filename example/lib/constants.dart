import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class Constants {
  static const fontFamily = 'Roboto';
  static const monoFontFamily = 'RobotoMono';

  static const linkColor = Colors.blue;
  static final codeBorderColor = Colors.red[300];
  static final codeTextColor = Colors.red[200];
  static const quoteBorderColor = Colors.deepOrange;
  static final codeBlockBackgroundColor = Colors.grey[200];
  static final codeBlockBorderColor = codeBlockBackgroundColor;
  static const codeBlockTextColor = Colors.black54;

  static final dateTimeFormat = DateFormat.yMEd();

  static const rootStyle = TextStyle(
    fontSize: 18,
    fontFamily: fontFamily,
  );

  static const appTitleText = 'Tdmarkup Example';
  static const loadingText = 'Loading...';

  static const assetJsonMessagePath = 'assets/example_message.json';
}
