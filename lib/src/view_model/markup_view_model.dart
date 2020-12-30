import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:characters/characters.dart';
import 'package:tdproto_dart/tdproto_dart.dart';

import 'package:tdmarkup_dart/tdmarkup_dart.dart';

/// Hosts a whole markup tree.
class MarkupViewModel {
  /// Top-level [MarkupNode]s.
  final List<MarkupNode> children;

  /// Format to convert [DateTime] to [String] for [TextType.time].
  final DateFormat dateTimeFormat;

  const MarkupViewModel({
    @required this.dateTimeFormat,
    @required this.children,
  });

  factory MarkupViewModel.fromMarkupEntities({
    @required DateFormat dateTimeFormat,
    @required List<MarkupEntity> markup,
    @required String initialText,
  }) {
    return MarkupViewModel(
      dateTimeFormat: dateTimeFormat,
      children: _mapMarkupChildrenToNodeList(
        dateTimeFormat: dateTimeFormat,
        children: markup,
        inheritedText: initialText,
      ),
    );
  }

  static List<MarkupNode> _mapMarkupChildrenToNodeList({
    @required DateFormat dateTimeFormat,
    @required List<MarkupEntity> children,
    @required String inheritedText,
  }) {
    // [inheritedText.characters] is required to handle emojis properly.
    // See: https://medium.com/dartlang/dart-string-manipulation-done-right-5abd0668ba3e
    final inheritedTextCharList = inheritedText.characters
        .split(
          ''.characters,
        )
        .toList();
    final mappedChildren = <MarkupNode>[];

    var lastIndex = 0;
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
                // This null check is required due to [entity.openLength]
                // can be null for some markup types.
                entity.open + (entity.openLength ?? 0),
                entity.close,
              )
              .join();

      if (!entity.childs.isEmptyOrNull) {
        mappedChildren.add(
          StyleNode(
            type: entityTextType,
            url: entity.url,
            children: _mapMarkupChildrenToNodeList(
              children: entity.childs,
              inheritedText: innerText,
              dateTimeFormat: dateTimeFormat,
            ),
          ),
        );
      } else if (entityTextType == TextType.plain) {
        mappedChildren.add(
          TextNode(text: innerText),
        );
      } else if (entityTextType == TextType.time) {
        mappedChildren.add(
          StyleNode(
            type: entityTextType,
            children: [
              TextNode(
                text: dateTimeFormat.format(entity.time.toLocal()),
              ),
            ],
          ),
        );
      } else {
        mappedChildren.add(
          StyleNode(
            type: entityTextType,
            url: entity.url,
            children: [
              TextNode(text: innerText),
            ],
          ),
        );
      }

      // This null check is required due to [entity.closeLength] can be null for some markup types.
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
