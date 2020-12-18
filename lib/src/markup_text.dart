import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:dart_extensions/dart_extensions.dart';

import 'package:tdmarkup/tdmarkup.dart';

typedef LaunchLink = Future<void> Function(String url);

/// Builds one resulting widget that represents markup.
///
/// Uses under hood: [RichText] for hosting [InlineSpan]s inside widget layer;
/// [TextSpan] to nest child [TextSpan]s and build an inline markup content such as link,
/// italic, bold;
/// [WidgetSpan] to build a block markup content such as quote and codeblock.
class MarkupText extends StatelessWidget {
  final TextStyle _rootStyle;
  final MarkupViewModel viewModel;
  final LaunchLink launchLink;
  final DateFormat dateTimeFormat;
  final Color linkColor;
  final Color codeBorderColor;
  final Color codeBackgroundColor;
  final String monoFontFamily;
  final Color quoteBorderColor;
  final Color codeBlockBackgroundColor;
  final Color codeBlockBorderColor;
  final Color codeBlockTextColor;

  const MarkupText({
    Key key,
    @required style,
    @required this.viewModel,
    @required this.launchLink,
    @required this.dateTimeFormat,
    @required this.linkColor,
    @required this.codeBorderColor,
    @required this.codeBackgroundColor,
    @required this.monoFontFamily,
    @required this.quoteBorderColor,
    @required this.codeBlockBackgroundColor,
    @required this.codeBlockBorderColor,
    @required this.codeBlockTextColor,
  })  : _rootStyle = style,
        super(key: key);

  @override
  Widget build(BuildContext context) => _buildMarkup(context, viewModel);

  Widget _buildMarkup(BuildContext context, MarkupViewModel viewModel) {
    return Text.rich(
      // root text span
      TextSpan(
        style: _rootStyle,
        children: _buildMarkupChildren(
          context: context,
          parent: null, // TODO: Fix this.
          children: viewModel.children,
        ),
      ),
    );
  }

  List<TextDecoration> _constructNewDecorations(
    List<TextDecoration> oldDecorations,
    TextDecoration currentDecoration,
  ) {
    if (currentDecoration != null && !oldDecorations.contains(currentDecoration)) {
      return [...oldDecorations, currentDecoration];
    } else {
      return [...oldDecorations];
    }
  }

  List<InlineSpan> _buildMarkupChildren({
    @required BuildContext context,
    @required MarkupNode parent,
    @required List<MarkupNode> children,
    List<TextDecoration> inheritedDecorations = const [],
    TapGestureRecognizer inheritedRecognizer,
  }) {
    // const monoFontFamily = 'RobotoMono';
    // final theme = Theme.of(context);

    return children.map((node) {
      /// Helps to create [TextSpan] with as few parameters as possible to keep the code simple.
      ///
      /// [recognizer] is not inherited by flutter, handles taps on link and its nested children.
      /// [recognizer] is passed down to the most deep children due to it only handles taps
      /// if there is an owh text on [TextSpan] set through [TextSpans]'s text parameter.
      ///
      /// [decoration] and [newDecoration] is for combining [TextDecoration.lineThrough] and
      /// [TextDecoration.underline] due to they are not properly inherited by flutter.
      ///
      /// [sourceTextStyle] is for [WidgetSpan]s which doesn't inherit [TextStyle] properly through flutter.
      TextSpan _buildTextSpanForCurrentNode({
        TapGestureRecognizer recognizer,
        TextDecoration decoration,
        List<TextDecoration> newDecorations,
        TextStyle sourceTextStyle,
        String text,
        FontWeight fontWeight,
        FontStyle fontStyle,
        Color color,
        String fontFamily,
        List<String> fontFamilyFallback,
        double height,
      }) {
        final textStyleToCopy = sourceTextStyle ?? const TextStyle();
        return TextSpan(
          text: text,
          recognizer: recognizer ?? inheritedRecognizer,
          style: textStyleToCopy.copyWith(
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            color: color,
            fontFamily: fontFamily,
            fontFamilyFallback: fontFamilyFallback,
            height: height,
          ),
          children: node.children.isEmptyOrNull
              ? null
              : _buildMarkupChildren(
                  context: context,
                  parent: node,
                  children: node.children,
                  inheritedDecorations: newDecorations ?? inheritedDecorations,
                  inheritedRecognizer: recognizer ?? inheritedRecognizer,
                ),
        );
      }

      switch (node.type) {
        case TextType.unsafe:
          return _buildTextSpanForCurrentNode(
            text: node.text, // treated as regular text,  no need to escape html in flutter
          );

        case TextType.plain:
          if (parent.type == TextType.time) {
            // temporal time parsing due to the bug with json_serializable's type casts
            // when adding toJson and fromJson parameters to @JsonKey annotation
            final dateTime = DateTime.parse(node.text).toLocal();
            return _buildTextSpanForCurrentNode(
              text: dateTimeFormat.format(dateTime),
            );
          } else {
            return _buildTextSpanForCurrentNode(
              text: node.text,
            );
          }
          // for linter (The last statement of the 'case' should be 'break',
          // 'continue', 'rethrow', 'return', or 'throw'.)
          break;

        case TextType.bold:
          return _buildTextSpanForCurrentNode(
            fontWeight: FontWeight.bold,
          );

        case TextType.italic:
          return _buildTextSpanForCurrentNode(
            fontStyle: FontStyle.italic,
          );

        case TextType.strike:
          final newDecorations = _constructNewDecorations(
            inheritedDecorations,
            TextDecoration.lineThrough,
          );
          return _buildTextSpanForCurrentNode(
            decoration: TextDecoration.combine(newDecorations),
            newDecorations: newDecorations,
          );

        case TextType.underscore:
          final newDecorations = _constructNewDecorations(
            inheritedDecorations,
            TextDecoration.underline,
          );
          return _buildTextSpanForCurrentNode(
            decoration: TextDecoration.combine(newDecorations),
            newDecorations: newDecorations,
          );

        case TextType.time:
          return _buildTextSpanForCurrentNode();

        case TextType.link:
          return _buildTextSpanForCurrentNode(
            color: linkColor,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                return launchLink(node.url);
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
                  color: codeBorderColor,
                ),
              ),
              child: Text.rich(
                _buildTextSpanForCurrentNode(
                  sourceTextStyle: _rootStyle,
                  color: codeBackgroundColor,
                  fontFamily: monoFontFamily,
                ),
              ),
            ),
          );

        case TextType.quote:
          return WidgetSpan(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2,
                    color: quoteBorderColor,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text.rich(
                  _buildTextSpanForCurrentNode(
                    sourceTextStyle: _rootStyle,
                    decoration: TextDecoration.combine(inheritedDecorations),
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
                color: codeBlockBackgroundColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  width: 1,
                  color: codeBlockBorderColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text.rich(
                  _buildTextSpanForCurrentNode(
                    sourceTextStyle: _rootStyle,
                    color: codeBlockTextColor,
                    fontFamily: monoFontFamily,
                    decoration: TextDecoration.combine(inheritedDecorations),
                  ),
                ),
              ),
            ),
          );

        default:
          throw Exception('Unsupported markup type');
      }
    }).toList();
  }
}
