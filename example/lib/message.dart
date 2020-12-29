import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tdproto_dart/tdproto_dart.dart';

Future<Map<String, dynamic>> _loadJsonFromAsset(String path) async {
  final jsonString = await rootBundle.loadString(path);
  return jsonDecode(jsonString);
}

List<MarkupEntity> _serializeMarkup(List<dynamic> markup) {
  return markup.map((json) => MarkupEntity.fromJson(json)).toList();
}

class Message {
  final String text;
  final List<MarkupEntity> markup;

  const Message({
    @required this.text,
    @required this.markup,
  });

  static Future<Message> loadFromJsonAsset(String path) async {
    final json = await _loadJsonFromAsset(path);
    return Message(
      text: json['text'],
      markup: _serializeMarkup(json['markup']),
    );
  }
}
