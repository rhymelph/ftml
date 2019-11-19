import 'package:flutter/material.dart';

import 'custom/a_text.dart';
import 'custom/h_text.dart';
import 'custom/p_text.dart';
import 'ftml.dart';
import 'ftml_text_base.dart';

class DefaultFtmlTextBuilder extends FtmlTextBuilder {
  @override
  TextSpan build(String data, {TextStyle textStyle, FtmlTextTapCalBack onTap}) {
    return super.build(data, textStyle: textStyle, onTap: onTap);
  }

  @override
  FtmlTextBase createFtmlText(String tag,
      {TextStyle textStyle, FtmlTextTapCalBack onTap, int index}) {
    if (tag == null || tag == '') return null;
    List<FtmlTextBase> baseList = [
      PText(textStyle, onTap, start: index),
      HText(textStyle, onTap, start: index),
      AText(textStyle, onTap, start: index),
    ];

    for (FtmlTextBase base in baseList) {
      if (base.isStart(tag)) {
        return base;
      }
    }
    return null;
  }
}

abstract class FtmlTextBuilder {
  TextSpan build(String data, {TextStyle textStyle, FtmlTextTapCalBack onTap}) {
    if (data == null) return null;
    List<InlineSpan> inlineList = [];

    if (data.length > 0) {
      FtmlTextBase ftmlText;
      StringBuffer textStack = StringBuffer();
      int level = 0; //防止多个相同标签嵌套

      for (int i = 0; i < data.length; i++) {
        int chat = data.codeUnitAt(i);
        textStack.writeCharCode(chat);

        if (ftmlText != null) {
          //判断当前是否为空，进行添加
          if (!ftmlText.isEnd(textStack.toString())) {
            if (ftmlText.isEndStart(textStack.toString())) {
              level += 1;
            }
            ftmlText.addChatContent(chat);
          } else {
            if (level != 0) {
              ftmlText.addChatContent(chat);
              level -= 1;
            } else {
              ftmlText.finish(chat);
              inlineList.add(ftmlText.finishText());
              ftmlText = null;
              textStack.clear();
            }
          }
        } else {
          ftmlText = createFtmlText(textStack.toString(),
              textStyle: textStyle, onTap: onTap, index: i);
          if (ftmlText != null) {
            if (textStack.length - ftmlText.startTag.length >= 0) {
              String content = textStack.toString();
              //获取下一个标签的内容
              content = content.substring(
                  0, content.length - ftmlText.startTag.length);
              if (content.length > 0) {
                inlineList.add(TextSpan(text: content, style: textStyle));
              }
            }
            textStack.clear();
          }
        }
      }

      if (ftmlText != null) {
        inlineList.add(TextSpan(
            text: ftmlText.startTag + ftmlText.content, style: textStyle));
      } else if (textStack.length > 0) {
        inlineList.add(TextSpan(text: textStack.toString(), style: textStyle));
      }
    } else {
      inlineList.add(TextSpan(text: data, style: textStyle));
    }
    return TextSpan(children: inlineList, style: textStyle);
  }

  FtmlTextBase createFtmlText(String tag,
      {TextStyle textStyle, FtmlTextTapCalBack onTap, int index});

  /// 是否已经开始了
  /// [value] 开始的值
  /// [startTag] 开始标签
  bool isStart(String value, String startTag) {
    return value.endsWith(startTag);
  }
}
