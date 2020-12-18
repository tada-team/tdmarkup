import 'package:tdmarkup/tdmarkup.dart';

abstract class IMarkupNode {
  TextType get type;
  String get text;
  String get url;
  List<IMarkupNode> get children;
}
