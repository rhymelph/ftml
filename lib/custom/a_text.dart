import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ftml/span/ftml_text_span.dart';

import '../ftml_text_base.dart';

class AText extends FtmlTextBase {
  final int start;

  AText(TextStyle textStyle, FtmlTextTapCalBack onTap, {this.start})
      : super(['a'], textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    TextStyle textStyle = this.textStyle?.copyWith(
        color: Colors.blue, fontSize: 16, decoration: TextDecoration.underline);
    String aText = toString();

    String text = element.text;
    String href = element.attributes['href'] ?? '';

    return FtmlTextSpan(
        text: text,
        actualText: aText,
        start: start,
        style: textStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            this.onTap?.call(href);
          });
  }
}
