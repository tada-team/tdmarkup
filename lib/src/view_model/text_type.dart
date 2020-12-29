import 'package:tdproto_dart/tdproto_dart.dart';

enum TextType {
  /// Text with no style, must only have text.
  plain,

  /// Bold style.
  bold,

  /// Italic style.
  italic,

  /// Underline style.
  underscore,

  /// Strikethrough style.
  strike,

  /// Code style.
  code,

  /// Code block style.
  codeBlock,

  /// Quote block style.
  quote,

  /// Link.
  link,

  /// Time with user's timezone.
  time,

  /// Unsafe HTML content, useful when using HTML.
  unsafe,
}

/// Maps markup type from tdproto_dart's implementation to tdmarkup_dart's implementation.
TextType mapMarkupTypeToTextType(MarkupType markupType) {
  switch (markupType) {
    case MarkupType.bold:
      return TextType.bold;

    case MarkupType.italic:
      return TextType.italic;

    case MarkupType.underscore:
      return TextType.underscore;

    case MarkupType.strike:
      return TextType.strike;

    case MarkupType.code:
      return TextType.code;

    case MarkupType.codeBlock:
      return TextType.codeBlock;

    case MarkupType.quote:
      return TextType.quote;

    case MarkupType.link:
      return TextType.link;

    case MarkupType.time:
      return TextType.time;

    case MarkupType.unsafe:
      return TextType.unsafe;
  }

  throw UnimplementedError('Unsupported markup type: $markupType');
}
