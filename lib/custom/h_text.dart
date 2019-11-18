import 'package:flutter/material.dart';
import 'package:ftml/span/ftml_text_span.dart';

import '../ftml_text_base.dart';

const _kMap = {
  'h1': TextStyle(
    color: Color(0xFF333333),
    fontSize: 28,
    fontWeight: FontWeight.w600,
  ),
  'h2': TextStyle(
    color: Color(0xFF333333),
    fontSize: 24,
    fontWeight: FontWeight.w600,
  ),
  'h3': TextStyle(
    color: Color(0xFF333333),
    fontSize: 20,
    fontWeight: FontWeight.w600,
  ),
  'h4': TextStyle(
    color: Color(0xFF333333),
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
  'h5': TextStyle(
    color: Color(0xFF333333),
    fontSize: 12,
    fontWeight: FontWeight.w600,
  ),
};

class HText extends FtmlTextBase {
  final int start;

  HText(TextStyle textStyle, FtmlTextTapCalBack onTap, {this.start})
      : super(_kMap.entries.map((m) => m.key).toList(), textStyle,
            onTap: onTap);

  @override
  InlineSpan finishText() {
    TextStyle textStyle =
        this.textStyle?.copyWith(color: Color(0xFF333333), fontSize: 26);

    textStyle = _kMap[tags[tagIndex]];
    return FtmlTextSpan(
      text: text,
      actualText: toString(),
      start: start,
      style: textStyle,
    );
  }
}
