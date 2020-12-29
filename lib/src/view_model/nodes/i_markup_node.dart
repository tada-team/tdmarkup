import 'package:tdmarkup_dart/tdmarkup_dart.dart';

abstract class IMarkupNode {
  TextType get type;
  String get text;
  String get url;
  List<IMarkupNode> get children;
}
