import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:tdmarkup_dart/tdmarkup_dart.dart';

/// Recursively builds all nested children of a node.
typedef _BuildMarkupChildren = List<InlineSpan> Function({
  BuildContext context,
  List<MarkupNode> children,
  MarkupNode parent,
  List<TextDecoration> inheritedDecorations,
  GestureRecognizer inheritedRecognizer,
});

/// Allows to bind properties to [BuildTextSpan] function via
/// instantiating this class and getting [BuildTextSpanBinder.buildTextSpan].
/// In other words [BuildTextSpanBinder.buildTextSpan] uses this class
/// as a namespace instead of using a closure.
class BuildTextSpanBinder {
  final BuildContext context;
  final List<TextDecoration> inheritedDecorations;
  final MarkupNode node;
  final GestureRecognizer inheritedRecognizer;
  final _BuildMarkupChildren buildMarkupChildren;

  const BuildTextSpanBinder({
    @required this.context,
    @required this.inheritedDecorations,
    @required this.node,
    @required this.buildMarkupChildren,
    this.inheritedRecognizer,
  });

  /// Builds [TextSpan] with inherited fields
  /// which flutter doesn't inherit by default.
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
    final newDecorations = _constructNewDecorations(
      inheritedDecorations,
      decoration,
    );
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
    if (currentDecoration != null &&
        !oldDecorations.contains(currentDecoration)) {
      return [...oldDecorations, currentDecoration];
    } else {
      return [...oldDecorations];
    }
  }
}
