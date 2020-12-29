import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:tdmarkup_dart/src/build_text_span_binder.dart';
import 'package:tdmarkup_dart/tdmarkup_dart.dart';

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

typedef InlineSpanBuilder = InlineSpan Function(Parameters params, BuildTextSpan buildTextSpan);

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
          parent: null,
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
      final constructor = BuildTextSpanBinder(
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
