import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tdmarkup_dart/tdmarkup_dart.dart';

import './message.dart';
import './constants.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Future<Message> _loadAssetFuture;

  @override
  void initState() {
    super.initState();
    _loadAssetFuture = Message.loadFromJsonAsset(Constants.assetJsonMessagePath);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appTitleText,
      home: Scaffold(
        body: Center(
          child: FutureBuilder<Message>(
            future: _loadAssetFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text(
                  Constants.loadingText,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                );
              } else {
                final message = snapshot.data;
                return MarkupText(
                  builder: _inlineSpanBuilder,
                  rootStyle: Constants.rootStyle,
                  viewModel: MarkupViewModel.fromMarkupEntities(
                    initialText: message.text,
                    markup: message.markup,
                    dateTimeFormat: Constants.dateTimeFormat,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _launchLink(String url) async {
    if (await canLaunch(url)) {
      return await launch(url);
    } else {
      return false;
    }
  }

  InlineSpan _inlineSpanBuilder(
    InlineSpanBuilderParams params,
    BuildTextSpan buildTextSpan,
  ) {
    final node = params.node;
    switch (node.type) {
      // unsafe type treated as regular text,  no need to escape html in flutter.
      case TextType.unsafe:
      case TextType.plain:
        return buildTextSpan(
          text: node.text,
        );

      case TextType.time:
        // We don't apply any specific style here and just build children.
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
          color: Constants.linkColor,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _launchLink(node.url);
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
                color: Constants.codeBorderColor,
              ),
            ),
            child: Text.rich(
              buildTextSpan(
                sourceTextStyle: Constants.rootStyle,
                color: Constants.codeTextColor,
                fontFamily: Constants.fontFamily,
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
                  color: Constants.quoteBorderColor,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text.rich(
                buildTextSpan(
                  sourceTextStyle: Constants.rootStyle,
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
              color: Constants.codeBlockBackgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                width: 1,
                color: Constants.codeBlockBorderColor,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text.rich(
                buildTextSpan(
                  sourceTextStyle: Constants.rootStyle,
                  color: Constants.codeBlockTextColor,
                  fontFamily: Constants.monoFontFamily,
                ),
              ),
            ),
          ),
        );

      default:
        throw UnimplementedError('Unsupported markup type: ${node.type}');
    }
  }
}
