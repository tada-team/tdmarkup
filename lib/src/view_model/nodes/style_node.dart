import 'package:meta/meta.dart';

import 'package:tdmarkup_dart/tdmarkup_dart.dart';

/// Represents a style applied to a group of nodes.
///
/// Must have type and not empty children.
class StyleNode extends MarkupNode {
  StyleNode({
    @required type,
    @required children,
    url,
  }) : super(
          type: type,
          url: url,
          children: children,
        );
}
