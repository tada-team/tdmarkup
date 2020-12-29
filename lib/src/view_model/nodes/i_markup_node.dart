import 'package:tdmarkup_dart/tdmarkup_dart.dart';

abstract class IMarkupNode {
  /// Text type.
  TextType get type;

  /// Own text content.
  String get text;

  /// Direct url for [TextType.link].
  String get url;

  /// Nested [IMarkupNode]s.
  List<IMarkupNode> get children;
}
