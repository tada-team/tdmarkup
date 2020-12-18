import 'package:tdproto_dart/tdproto_dart.dart';

enum TextType {
  plain,

  bold,
  italic,
  underscore,
  strike,
  code,
  codeBlock,
  quote,
  link,
  time,
  unsafe,
}

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

  throw AssertionError();
}
