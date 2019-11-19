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

  String get endTag => tags[tagIndex]=='img'?'>':'</${tags[tagIndex]}>';

  FtmlTextBase(
    this.tags,
    this.textStyle, {
    this.onTap,
  }) : _content = StringBuffer();

  bool isStart(String value) {
    if(tags.length==1){
      String tag=tags[tagIndex];
      return value.endsWith('<$tag');
    }else{
      Map<int, String> tagsMap = tags.asMap();
      for (MapEntry<int, String> tag in tagsMap.entries) {
        if (value.endsWith('<${tag.value}')) {
          tagIndex = tag.key;
          return true;
        }
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

  Color get color => getColorValue(attributes['color']);

  //文本样式
  Color get fontColor => getColorValue(attributes['font-color']);

  double get fontSize => getDoubleValue(attributes['font-size'], 24);

  ///[w100, w200, w300, w400, w500, w600, w700, w800, w900]
  int get fontWeight => getIntValue(attributes['font-weight'], 3);

  /// padding
  double get paddingLeft =>
      getDoubleValue(element.attributes['paddingleft']) ?? padding.elementAt(0);

  double get paddingTop =>
      getDoubleValue(element.attributes['paddingtop']) ?? padding.elementAt(1);

  double get paddingRight =>
      getDoubleValue(element.attributes['paddingright']) ??
      padding.elementAt(2);

  double get paddingBottom =>
      getDoubleValue(element.attributes['paddingbottom']) ??
      padding.elementAt(3);

  List<double> get padding {
    List<double> result=getListDoubleValue(element.attributes['padding'], [0.0, 0.0, 0.0, 0.0]);
    if (result.length < 4) {
      result.addAll(List.generate(4 - result.length, (int index) => 0.0));
    }
    return result;
  }

  /// margin
  double get marginLeft =>
      getDoubleValue(element.attributes['marginleft']) ?? margin.elementAt(0);

  double get marginTop =>
      getDoubleValue(element.attributes['margintop']) ?? margin.elementAt(1);

  double get marginRight =>
      getDoubleValue(element.attributes['marginright']) ?? margin.elementAt(2);

  double get marginBottom =>
      getDoubleValue(element.attributes['marginbottom']) ?? margin.elementAt(3);

  List<double> get margin {
    List<double> result=getListDoubleValue(element.attributes['margin'], [0.0, 0.0, 0.0, 0.0]);
    if (result.length < 4) {
      result.addAll(List.generate(4 - result.length, (int index) => 0.0));
    }
    return result;
  }

  @override
  String toString() {
    return '$startTag$content$endTag';
  }

  //获取颜色
  Color getColorValue(String value) {
    if (value == null) return null;
    if (value.startsWith('#')) {
      if (value.length == 7) {
        value = value.replaceAll('#', '0xFF');
      } else {
        value = value.replaceAll('#', '0x');
      }
    }
    if (value.startsWith('0x') && value.length == 8) {
      value = value.replaceAll('0x', '0xFF');
    }
    int intValue = int.parse(value, onError: (e) => null);
    if (intValue == null) return null;
    return Color(intValue);
  }

  //获取double值
  double getDoubleValue(String value, [double def]) {
    if (value == null) return def;
    return double.parse(value ?? 'null', (e) => def);
  }

  //获取int值
  int getIntValue(String value, [int def]) {
    if (value == null) return def;
    return int.parse(value ?? 'null', onError: (e) => def);
  }

  List<String> getListStringValue(String value, [List<String> def]) {
    if (value == null) return def;
    return value.split(',');
  }

  List<double> getListDoubleValue(String value, [List<double> def]) {
    if (value == null) return def;
    return value.split(',').map((s) => getDoubleValue(s)).toList();
  }
}
