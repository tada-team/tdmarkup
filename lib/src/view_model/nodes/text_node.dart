import 'package:meta/meta.dart';

import 'package:tdmarkup_dart/tdmarkup_dart.dart';

/// Represents outermost node type which can only contain text.
class TextNode extends MarkupNode {
  TextNode({
    @required text,
  }) : super(
          type: TextType.plain,
          text: text,
        );
}
