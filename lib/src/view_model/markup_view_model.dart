import 'package:meta/meta.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:characters/characters.dart';
import 'package:tdproto_dart/tdproto_dart.dart';

import 'package:tdmarkup/tdmarkup.dart';

/// Represents the host node for a whole markup tree.
///
/// Must be the first node in a markup tree.
///
/// Can only have children property.
class MarkupViewModel {
  final List<MarkupNode> children;

  MarkupViewModel({
    @required this.children,
  });

  factory MarkupViewModel.fromMarkupEntities(List<MarkupEntity> markup, String initialText) {
    return MarkupViewModel(
      children: _mapMarkupChildrenToNodeList(markup, initialText),
    );
  }

  static List<MarkupNode> _mapMarkupChildrenToNodeList(
    List<MarkupEntity> children,
    String inheritedText,
  ) {
    // [inheritedTextCharList] is required to handle emojis properly.
    // See: https://medium.com/dartlang/dart-string-manipulation-done-right-5abd0668ba3e
    final inheritedTextCharList = inheritedText.characters.split(''.characters).toList();
    final mappedChildren = <MarkupNode>[];

    int lastIndex = 0;
    for (final entity in children) {
      final entityTextType = mapMarkupTypeToTextType(entity.type);

      if (entity.open > lastIndex) {
        // Adds a plain intermediate piece of text.
        mappedChildren.add(
          TextNode(
            text: inheritedTextCharList
                .sublist(
                  lastIndex,
                  entity.open,
                )
                .join(),
          ),
        );
      }

      final innerText = entityTextType == TextType.link
          ? entity.repl
          : inheritedTextCharList
              .sublist(
                // This null check is required due to [entity.openingMarkerLength] can be null for some markup types.
                entity.open + (entity.openLength ?? 0),
                entity.close,
              )
              .join();

      if (!entity.childs.isEmptyOrNull) {
        mappedChildren.add(
          StyleNode(
            type: entity.type,
            url: entity.url,
            children: _mapMarkupChildrenToNodeList(
              entity.childs,
              innerText,
            ),
          ),
        );
      } else if (entityTextType == TextType.plain) {
        mappedChildren.add(
          TextNode(text: innerText),
        );
      } else {
        mappedChildren.add(
          StyleNode(
            type: entity.type,
            url: entity.url,
            children: [
              TextNode(text: innerText),
            ],
          ),
        );
      }

      // This null check is required due to [entity.closingMarkerLength] can be null for some markup types.
      lastIndex = entity.close + (entity.closeLength ?? 0);
    }

    if (lastIndex < inheritedTextCharList.length) {
      // Adds the last plain piece of text.
      mappedChildren.add(
        TextNode(
          text: inheritedTextCharList
              .sublist(
                lastIndex,
                inheritedTextCharList.length,
              )
              .join(),
        ),
      );
    }

    return mappedChildren;
  }
}
