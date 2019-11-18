import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

typedef FtmlTextTapCalBack = void Function(dynamic param);

abstract class FtmlTextBase {
  List<String> tags;
  int tagIndex = 0;

  FtmlTextTapCalBack onTap;

  TextStyle textStyle;

  StringBuffer _content;

  InlineSpan finishText();

  String get startTag => '<${tags[tagIndex]}';

  String get endTag => '</${tags[tagIndex]}>';

  FtmlTextBase(
    this.tags,
    this.textStyle, {
    this.onTap,
  }) : _content = StringBuffer();

  bool isStart(String value) {
    Map<int, String> tagsMap = tags.asMap();
    for (MapEntry<int, String> tag in tagsMap.entries) {
      if (value.endsWith('<${tag.value}')) {
        tagIndex = tag.key;
        return true;
      }
    }
    return false;
  }

  bool isEnd(String value) {
    return value.endsWith(endTag);
  }

  bool isEndStart(String value) {
    return value.endsWith(startTag);
  }

  void addContent(String value) {
    _content.write(value);
  }

  void addChatContent(int chat) {
    _content.writeCharCode(chat);
  }

  void finish(int chat) {
    addChatContent(chat);
    String finishText = _content.toString();
    finishText = finishText.substring(0, finishText.length - endTag.length);
    _content.clear();
    _content.write(finishText);
  }

  String get content => _content.toString();

  //获取dom
  dom.Document get document => parse(toString());

  dom.Element get element =>
      document.getElementsByTagName(tags[tagIndex]).first;

  //标签文本
  String get text => element.text;

  //内嵌html标签
  String get innerHtml => element.innerHtml;

  //属性
  LinkedHashMap<dynamic, String> get attributes => element.attributes;

  Color get color {
    return getColorValue(attributes['color']);
  }

  Color get textColor {
    return getColorValue(attributes['textcolor']);
  }

  //获取颜色
  Color getColorValue(String value) {
    if (value == null) return null;
    if (value.contains('#')) {
      if (value.length == 7) {
        value = value.replaceAll('#', '0xFF');
      } else {
        value = value.replaceAll('#', '0x');
      }
    }
    if (value.contains('0x') && value.length == 9) {
      value = value.replaceAll('0x', '0xFF');
    }
    print(value);
    int intValue = int.parse(value, onError: (e) => null);
    print(intValue);
    if (intValue == null) return null;
    return Color(intValue);
  }

  /// padding
  double get paddingLeft =>
      double.parse(element.attributes['paddingleft'] ?? 'null', (e) => null) ??
      padding.elementAt(0);

  double get paddingTop =>
      double.parse(element.attributes['paddingtop'] ?? 'null', (e) => null) ??
      padding.elementAt(1);

  double get paddingRight =>
      double.parse(element.attributes['paddingright'] ?? 'null', (e) => null) ??
      padding.elementAt(2);

  double get paddingBottom =>
      double.parse(
          element.attributes['paddingbottom'] ?? 'null', (e) => null) ??
      padding.elementAt(3);

  List<double> get padding {
    if (element.attributes['padding'] == null)
      return List.generate(4, (_) => 0.0);

    List<double> result = element.attributes['padding']
        .split(',')
        .map((s) => double.parse(s, (s) => 0.0))
        .toList();
    if (result.length < 4) {
      result.addAll(List.generate(4 - result.length, (int index) => 0.0));
    }
    return result;
  }

  /// margin
  double get marginLeft =>
      double.parse(element.attributes['marginleft'] ?? '0', (e) => null) ??
      margin.elementAt(0);

  double get marginTop =>
      double.parse(element.attributes['margintop'] ?? '0', (e) => null) ??
      margin.elementAt(1);

  double get marginRight =>
      double.parse(element.attributes['marginright'] ?? '0', (e) => null) ??
      margin.elementAt(2);

  double get marginBottom =>
      double.parse(element.attributes['marginbottom'] ?? '0', (e) => null) ??
      margin.elementAt(3);

  List<double> get margin {
    if (element.attributes['margin'] == null)
      return List.generate(4, (_) => 0.0);

    List<double> result = element.attributes['margin']
        .split(',')
        .map((s) => double.parse(s, (s) => 0.0))
        .toList();
    if (result.length < 4) {
      result.addAll(List.generate(4 - result.length, (int index) => 0.0));
    }
    return result;
  }

  @override
  String toString() {
    return '$startTag$content$endTag';
  }
}
