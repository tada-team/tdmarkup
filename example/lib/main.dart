import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tdproto_dart/tdproto_dart.dart';
import 'package:tdmarkup_dart/tdmarkup_dart.dart';

void main() => runApp(App());

// TODO: Вынести json контент в файл.

const text =
    '> ultimate quote\n/0 _1 *2 ~34~ 6* 7_ 8/\nplain text\nhttps://ya.ru/\n`code: print(true)`\n```for (final item in list) {\n\tprint(item);\n}```\ntime: <2020-11-15T13:50:44.147000Z>';

const jsonMarkup = [
  {
    'op': 0,
    'oplen': 2,
    'cl': 16,
    'cllen': 1,
    'typ': 'quote',
  },
  {
    'op': 17,
    'oplen': 1,
    'cl': 38,
    'cllen': 1,
    'typ': 'italic',
    'childs': [
      {
        'op': 2,
        'oplen': 1,
        'cl': 17,
        'cllen': 1,
        'typ': 'underscore',
        'childs': [
          {
            'op': 2,
            'oplen': 1,
            'cl': 11,
            'cllen': 1,
            'typ': 'bold',
            'childs': [
              {
                'op': 2,
                'oplen': 1,
                'cl': 5,
                'cllen': 1,
                'typ': 'strike',
              }
            ]
          }
        ]
      }
    ]
  },
  {
    'op': 51,
    'cl': 65,
    'typ': 'link',
    'url': 'https://ya.ru/',
    'repl': 'ya.ru',
  },
  {
    'op': 66,
    'oplen': 1,
    'cl': 84,
    'cllen': 1,
    'typ': 'code',
  },
  {
    'op': 86,
    'oplen': 3,
    'cl': 131,
    'cllen': 3,
    'typ': 'codeblock',
  },
  {
    'op': 141,
    'oplen': 1,
    'cl': 169,
    'cllen': 1,
    'typ': 'time',
    'time': '2020-11-15T13:50:44.147000Z',
  }
];

List<MarkupEntity> getMarkupEntities(List<Map<String, dynamic>> jsonList) {
  return jsonList.map((json) => MarkupEntity.fromJson(json)).toList();
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tdmarkup Example',
      home: Scaffold(
        body: Center(
          child: MarkupText(
            builder: _inlineSpanBuilder,
            rootStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
            viewModel: MarkupViewModel.fromMarkupEntities(
              dateTimeFormat: DateFormat.yMEd(),
              markup: getMarkupEntities(jsonMarkup),
              initialText: text,
            ),
          ),
        ),
      ),
    );
  }

  InlineSpan _inlineSpanBuilder(Parameters params, BuildTextSpan buildTextSpan) {
    // TODO: Remove this mock.
    const _rootStyle = TextStyle(
      fontSize: 18,
      fontFamily: 'Roboto',
    );

    final node = params.node;
    switch (node.type) {
      // unsafe treated as regular text,  no need to escape html in flutter
      case TextType.unsafe:
      case TextType.plain:
        return buildTextSpan(
          text: node.text,
        );

      case TextType.time:
        // Вставка детей происходит автоматически.
        // TODO: Сделать чтобы вставка детей была понятнее.
        return buildTextSpan();

      case TextType.bold:
        return buildTextSpan(
          fontWeight: FontWeight.bold,
        );

      case TextType.italic:
        return buildTextSpan(
          fontStyle: FontStyle.italic,
        );

      case TextType.strike:
        return buildTextSpan(
          decoration: TextDecoration.lineThrough,
        );

      case TextType.underscore:
        return buildTextSpan(
          decoration: TextDecoration.underline,
        );

      case TextType.link:
        return buildTextSpan(
          // TODO: Remove this hardcoded value.
          color: Colors.blue,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              // TODO: Remove this mock.
              print(node.url);
            },
        );

      case TextType.code:
        return WidgetSpan(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                width: 1,
                // TODO: Remove this mock.
                color: Colors.brown,
              ),
            ),
            child: Text.rich(
              buildTextSpan(
                sourceTextStyle: _rootStyle,
                color: Colors.brown, // TODO: Remove this mock.
                fontFamily: 'RobotoMono', // TODO: Remove this mock.
              ),
            ),
          ),
        );

      case TextType.quote:
        return WidgetSpan(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 2,
                  // TODO: Remove this mock.
                  color: Colors.yellow,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text.rich(
                buildTextSpan(
                  sourceTextStyle: _rootStyle,
                ),
              ),
            ),
          ),
        );

      case TextType.codeBlock:
        return WidgetSpan(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.pink, // TODO: Remove this mock.
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                width: 1,
                color: Colors.green, // TODO: Remove this mock.
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text.rich(
                buildTextSpan(
                  sourceTextStyle: _rootStyle,
                  color: Colors.orange, // TODO: Remove this mock.
                  fontFamily: 'RobotoMono', // TODO: Remove this mock.
                ),
              ),
            ),
          ),
        );

      default:
        throw Exception('Unsupported markup type');
    }
  }
}
