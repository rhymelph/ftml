import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class FtmlTextSpan extends TextSpan with FtmlInlineSpanBase {
  @override
  final String actualText;

  @override
  final TextRange textRange;

  FtmlTextSpan({
    TextStyle style,
    @required String text,
    @required String actualText,
    int start: 0,
    GestureRecognizer recognizer,
  })  : assert(start != null),
        assert(text != null),
        actualText = actualText ?? text,
        textRange =
            TextRange(start: start, end: start + (actualText ?? text).length),
        super(style: style, text: text, recognizer: recognizer);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is FtmlTextSpan &&
          runtimeType == other.runtimeType &&
          actualText == other.actualText &&
          textRange == other.textRange;

  @override
  int get hashCode => super.hashCode ^ actualText.hashCode ^ textRange.hashCode;

  @override
  RenderComparison compareTo(InlineSpan other) {
    var comparison = super.compareTo(other);
    if (comparison == RenderComparison.identical) {
      comparison = baseCompareTo(other as FtmlInlineSpanBase);
    }
    return super.compareTo(other);
  }
}

abstract class FtmlInlineSpanBase {
  String get actualText;

  TextRange get textRange;

  int get start => textRange.start;

  int get end => textRange.end;

  bool equal(FtmlInlineSpanBase other) =>
      other.start == start && other.actualText == actualText;

  int get baseHashCode => hashValues(actualText, start);

  RenderComparison baseCompareTo(FtmlInlineSpanBase other) {
    if (other.actualText != actualText) {
      return RenderComparison.paint;
    }
    if (other.start != start) {
      return RenderComparison.layout;
    }
    return RenderComparison.identical;
  }
}
