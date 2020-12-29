import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:tdmarkup_dart/tdmarkup_dart.dart';

// TODO: Упростить передачу rootTextStyle.
// TODO: Упростить ситуацию с [inheritedDecorations] и [inheritedRecognizer].
// TODO: Возможно нужно использовать не просто InlineSpan,
//  т.к. человек может не понять что работает наследование некоторых полей.

typedef LaunchLink = void Function(String url);

typedef InlineSpanBuilder = InlineSpan Function(Parameters params, BuildTextSpan buildTextSpan);

typedef BuildTextSpan = InlineSpan Function({
  GestureRecognizer recognizer,
  TextDecoration decoration,
  TextStyle sourceTextStyle,
  String text,
  FontWeight fontWeight,
  FontStyle fontStyle,
  Color color,
  String fontFamily,
  List<String> fontFamilyFallback,
  double height,
});

typedef _BuildMarkupChildren = List<InlineSpan> Function({
  BuildContext context,
  List<MarkupNode> children,
  MarkupNode parent,
  List<TextDecoration> inheritedDecorations,
  GestureRecognizer inheritedRecognizer,
});

class Parameters {
  final BuildContext context;
  final MarkupNode node;
  final MarkupNode parent;
  final List<TextDecoration> inheritedDecorations;
  final GestureRecognizer inheritedRecognizer;

  const Parameters({
    @required this.context,
    @required this.node,
    @required this.parent,
    @required this.inheritedDecorations,
    @required this.inheritedRecognizer,
  });
}

class _BuildTextSpanConstructor {
  final BuildContext context;
  final List<TextDecoration> inheritedDecorations;
  final MarkupNode node;
  final GestureRecognizer inheritedRecognizer;
  final _BuildMarkupChildren buildMarkupChildren;

  const _BuildTextSpanConstructor({
    @required this.context,
    @required this.inheritedDecorations,
    @required this.node,
    @required this.buildMarkupChildren,
    this.inheritedRecognizer,
  });

  TextSpan buildTextSpan({
    GestureRecognizer recognizer,
    TextDecoration decoration,
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
    final newDecorations = _constructNewDecorations(inheritedDecorations, decoration);
    return TextSpan(
      text: text,
      recognizer: recognizer ?? inheritedRecognizer,
      style: textStyleToCopy.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        decoration: TextDecoration.combine(newDecorations),
        color: color,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        height: height,
      ),
      children: node.children.isEmptyOrNull
          ? null
          : buildMarkupChildren(
              context: context,
              parent: node,
              children: node.children,
              inheritedDecorations: newDecorations,
              inheritedRecognizer: recognizer ?? inheritedRecognizer,
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
}

/// Builds one resulting widget that represents markup.
///
/// Uses under hood: [RichText] for hosting [InlineSpan]s inside widget layer;
/// [TextSpan] to nest child [TextSpan]s and build an inline markup content such as link,
/// italic, bold;
/// [WidgetSpan] to build a block markup content such as quote and codeblock.
class MarkupText extends StatelessWidget {
  final TextStyle rootStyle;
  final MarkupViewModel viewModel;
  final InlineSpanBuilder builder;

  const MarkupText({
    Key key,
    @required this.viewModel,
    @required this.rootStyle,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      // Root text span.
      TextSpan(
        style: rootStyle,
        children: _buildMarkupChildren(
          context: context,
          parent: null, // TODO: Fix this.
          children: viewModel.children,
        ),
      ),
    );
  }

  List<InlineSpan> _buildMarkupChildren({
    @required BuildContext context,
    @required List<MarkupNode> children,
    MarkupNode parent,
    List<TextDecoration> inheritedDecorations = const [],
    GestureRecognizer inheritedRecognizer,
  }) {
    return children.map((node) {
      final params = Parameters(
        node: node,
        context: context,
        parent: parent,
        inheritedDecorations: inheritedDecorations,
        inheritedRecognizer: inheritedRecognizer,
      );
      final constructor = _BuildTextSpanConstructor(
        node: node,
        context: context,
        buildMarkupChildren: _buildMarkupChildren,
        inheritedDecorations: inheritedDecorations,
        inheritedRecognizer: inheritedRecognizer,
      );

      return builder(params, constructor.buildTextSpan);
    }).toList();
  }
}
