import 'package:flutter/material.dart';

import '../ftml_text.dart';
import '../ftml_text_base.dart';
import '../ftml_text_builder.dart';

class PText extends FtmlTextBase {
  final int start;

  PText(TextStyle textStyle, FtmlTextTapCalBack onTap, {this.start})
      : super(['p'], textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    return WidgetSpan(
        child: Container(
      padding: EdgeInsets.only(
        left: paddingLeft,
        right: paddingRight,
        top: paddingTop,
        bottom: paddingBottom,
      ),
      margin: EdgeInsets.only(
        left: marginLeft,
        right: marginRight,
        top: marginTop,
        bottom: marginBottom,
      ),
      color: color,
      child: FtmlText(
        element.innerHtml,
        ftmlTextBuilder: DefaultFtmlTextBuilder(),
        onFtmlTextTap: (value) {
          onTap?.call(value);
        },
      ),
    ));
  }
}
