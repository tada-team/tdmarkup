import 'package:meta/meta.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:equatable/equatable.dart';

import 'package:tdmarkup/src/view_model/i_markup_node.dart';
import 'package:tdmarkup/src/view_model/text_type.dart';

/// Represents single markup unit.
///
/// Text property can only be present when type is [MarkupType.plain].
///
/// The origin of markup tree must be [RootNode].
///
/// Example for text "_1 *2 ~34~ 6* 7_"
/// ```dart
/// RootNode(
///   children: [
///     StyleNode(
///       type: MarkupType.underscore,
///       children: [
///         TextNode(text: '1 '),
///         StyleNode(
///           type: MarkupType.bold,
///           children: [
///             TextNode(text: '2 '),
///             StyleNode(
///               type: MarkupType.strikethrough,
///               children: [
///                 TextNode(text: '34'),
///               ],
///             ),
///             TextNode(text: ' 6'),
///           ],
///         ),
///         TextNode(text: ' 7'),
///       ],
///     ),
///   ],
/// );
/// ```
class MarkupNode extends Equatable implements IMarkupNode {
  @override
  final TextType type;
  @override
  final String text;
  @override
  final String url;
  @override
  final List<MarkupNode> children;

  MarkupNode({
    @required this.type,
    this.text,
    this.url,
    this.children,
  }) : assert(() {
          if (type == TextType.plain) {
            return !text.isEmptyOrNull && children.isEmptyOrNull;
          } else {
            return text.isEmptyOrNull && !children.isEmptyOrNull;
          }
        }());

  @override
  List<Object> get props => [type, text, url, children];
}
