import 'package:meta/meta.dart';

import 'package:tdmarkup/tdmarkup.dart';

/// Represents an applied style on a group of nodes.
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
