import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:tdmarkup_dart/src/build_text_span_binder.dart';
import 'package:tdmarkup_dart/tdmarkup_dart.dart';

/// Builds a [TextSpan] with inherited fields
/// which flutter doesn't inherit by default.
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

/// Requires you to provide own logic to build [InlineSpan]s.
/// You must provide an [InlineSpan] for each value in [TextType.values],
/// see the example in this project.
typedef InlineSpanBuilder = InlineSpan Function(
  InlineSpanBuilderParams params,
  BuildTextSpan buildTextSpan,
);

/// Helps to pass properties to [InlineSpanBuilder].
class InlineSpanBuilderParams {
  /// Current context.
  final BuildContext context;

  /// Current node for which [InlineSpanBuilder] builds an [InlineSpan].
  final MarkupNode node;

  /// Parent node that has a [MarkupNode.children] array
  /// that we are currently in.
  final MarkupNode parent;

  /// Inherited decorations passed and combined directly inside [BuildTextSpan],
  /// since flutter doesn't use [TextDecoration.combine]
  /// when inheriting [TextStyle.decoration].
  final List<TextDecoration> inheritedDecorations;

  /// Inherited [TextSpan.recognizer] passed down directly
  /// because flutter doesn't inherit it.
  final GestureRecognizer inheritedRecognizer;

  const InlineSpanBuilderParams({
    @required this.context,
    @required this.node,
    @required this.parent,
    @required this.inheritedDecorations,
    @required this.inheritedRecognizer,
  });
}

/// Builds one resulting widget that represents markup.
///
/// Uses under hood: [RichText] to host [InlineSpan]s inside widget layer;
/// [TextSpan] to nest child [TextSpan]s and build an inline markup content
/// such as [TextType.link], [TextType.bold];
/// [WidgetSpan] to build a block markup content
/// such as [TextType.quote] and [TextType.codeBlock].
class MarkupText extends StatelessWidget {
  /// Style for the root [TextSpan], this style will be inherited by children.
  final TextStyle rootStyle;

  /// View model.
  final MarkupViewModel viewModel;

  /// Requires you to provide own logic to build [InlineSpan]s.
  /// You must provide an [InlineSpan] for each value in [TextType.values],
  /// see the example in this project.
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

  /// Recursively builds all nested children of a node.
  List<InlineSpan> _buildMarkupChildren({
    @required BuildContext context,
    @required List<MarkupNode> children,
    MarkupNode parent,
    List<TextDecoration> inheritedDecorations = const [],
    GestureRecognizer inheritedRecognizer,
  }) {
    return children.map((node) {
      final params = InlineSpanBuilderParams(
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
