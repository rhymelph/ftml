import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'ftml_text_base.dart';
import 'ftml_text_builder.dart';
import 'span/ftml_text_span.dart';

class FtmlText extends StatelessWidget {
  final GestureDetector onTap;

  final String data;

  final FtmlTextBuilder ftmlTextBuilder;

  final FtmlTextTapCalBack onFtmlTextTap;

  final InlineSpan textSpan;

  final TextStyle style;

  final StrutStyle strutStyle;

  final TextAlign textAlign;

  final TextDirection textDirection;

  final Locale locale;

  final bool softWrap;

  final TextOverflow overflow;

  final double textScaleFactor;

  final int maxLines;

  final String semanticsLabel;

  final TextWidthBasis textWidthBasis;

  const FtmlText(this.data,
      {Key key,
      this.onTap,
      this.ftmlTextBuilder,
      this.onFtmlTextTap,
      this.style,
      this.strutStyle,
      this.textAlign,
      this.textDirection,
      this.locale,
      this.softWrap,
      this.overflow,
      this.textScaleFactor,
      this.maxLines,
      this.semanticsLabel,
      this.textWidthBasis})
      : assert(data != null),
        textSpan = null,
        super(key: key);

  const FtmlText.rich(this.textSpan,
      {Key key,
      this.onTap,
      this.onFtmlTextTap,
      this.style,
      this.strutStyle,
      this.textAlign,
      this.textDirection,
      this.locale,
      this.softWrap,
      this.overflow,
      this.textScaleFactor,
      this.maxLines,
      this.semanticsLabel,
      this.textWidthBasis})
      : assert(textSpan != null),
        data = null,
        ftmlTextBuilder = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);

    TextStyle effectiveTextStyle = style;
    if (style == null || style.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }

    if (MediaQuery.boldTextOverride(context)) {
      effectiveTextStyle = effectiveTextStyle
          .merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    DateTime time = DateTime.now();
    TextSpan innerTextSpan = ftmlTextBuilder?.build(data,
        textStyle: effectiveTextStyle, onTap: onFtmlTextTap);
    Duration duration = DateTime.now().difference(time);
    print('总耗时:${duration.inMilliseconds}毫秒');
    if (innerTextSpan == null) {
      innerTextSpan = TextSpan(
        style: effectiveTextStyle,
        text: data,
        children: textSpan != null ? [textSpan] : null,
      );
    }
    Widget result = FtmlRichText(
      text: innerTextSpan,
      textAlign: textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap ?? defaultTextStyle.softWrap,
      overflow: overflow ?? defaultTextStyle.overflow,
      textScaleFactor: textScaleFactor ?? MediaQuery.textScaleFactorOf(context),
      maxLines: maxLines ?? defaultTextStyle.maxLines,
    );

    if (semanticsLabel != null) {
      result = Semantics(
        textDirection: textDirection,
        label: semanticsLabel,
        child: ExcludeSemantics(
          child: result,
        ),
      );
    }

    return result;
  }
}

class FtmlRichText extends MultiChildRenderObjectWidget {
  final InlineSpan text;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int maxLines;
  final Locale locale;
  final StrutStyle strutStyle;
  final TextWidthBasis textWidthBasis;

  FtmlRichText(
      {Key key,
      @required this.text,
      this.textAlign = TextAlign.start,
      this.textDirection = TextDirection.ltr,
      this.softWrap = true,
      this.overflow = TextOverflow.clip,
      this.textScaleFactor = 1.0,
      this.maxLines,
      this.locale,
      this.strutStyle,
      this.textWidthBasis = TextWidthBasis.parent})
      : assert(text != null),
        assert(textAlign != null),
        assert(softWrap != null),
        assert(overflow != null),
        assert(textScaleFactor != null),
        assert(maxLines == null || maxLines > 0),
        assert(textWidthBasis != null),
        super(key: key, children: _extractChildren(text));

  static List<Widget> _extractChildren(InlineSpan span) {
    final List<Widget> result = [];
    span.visitChildren((InlineSpan span) {
      if (span is WidgetSpan) {
        result.add(span.child);
      }
      return true;
    });
    return result;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    assert(textDirection != null || debugCheckHasDirectionality(context));
    return FtmlRenderParagraph(text,
        textAlign: textAlign,
        softWrap: softWrap,
        overflow: overflow,
        textScaleFactor: textScaleFactor,
        maxLine: maxLines,
        strutStyle: strutStyle,
        textWidthBasis: textWidthBasis,
        locale: locale ??
            Localizations.localeOf(
              context,
              nullOk: true,
            ),
        textDirection: textDirection ?? Directionality.of(context));
  }

  @override
  void updateRenderObject(
      BuildContext context, FtmlRenderParagraph renderObject) {
    assert(textDirection != null || debugCheckHasDirectionality(context));
    renderObject
      ..text = text
      ..textAlign = textAlign
      ..textDirection = textDirection ?? Directionality.of(context)
      ..softWrap = softWrap
      ..overflow = overflow
      ..textScaleFactor = textScaleFactor
      ..maxLines = maxLines
      ..strutStyle = strutStyle
      ..textWidthBasis = textWidthBasis
      ..locale = locale ?? Localizations.localeOf(context, nullOk: true);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign,
        defaultValue: TextAlign.start));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(FlagProperty('softWrap',
        value: softWrap,
        ifTrue: 'wrapping at box width',
        ifFalse: 'no wrapping except at line break characters',
        showName: true));
    properties.add(EnumProperty<TextOverflow>('overflow', overflow,
        defaultValue: TextOverflow.clip));
    properties.add(
        DoubleProperty('textScaleFactor', textScaleFactor, defaultValue: 1.0));
    properties.add(IntProperty('maxLines', maxLines, ifNull: 'unlimited'));
    properties.add(EnumProperty<TextWidthBasis>(
        'textWidthBasis', textWidthBasis,
        defaultValue: TextWidthBasis.parent));
    properties.add(StringProperty('text', text.toPlainText()));
  }
}

const String _kEllipsis = '\u2026';

class FtmlRenderParagraph extends FtmlTextRenderBox {
  final TextPainter _textPainter;

  FtmlRenderParagraph(
    InlineSpan text, {
    TextAlign textAlign = TextAlign.start,
    @required TextDirection textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    double textScaleFactor = 1.0,
    int maxLine,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    Locale locale,
    StrutStyle strutStyle,
    List<RenderBox> children,
  })  : assert(text != null),
        assert(text.debugAssertIsValid()),
        assert(textAlign != null),
        assert(textDirection != null),
        assert(softWrap != null),
        assert(textScaleFactor != null),
        assert(maxLine == null || maxLine > 0),
        assert(textWidthBasis != null),
        _softWrap = softWrap,
        _overflow = overflow,
        _textPainter = TextPainter(
            text: text,
            textAlign: textAlign,
            textDirection: textDirection,
            textScaleFactor: textScaleFactor,
            maxLines: maxLine,
            locale: locale,
            ellipsis: overflow == TextOverflow.ellipsis ? _kEllipsis : null,
            strutStyle: strutStyle,
            textWidthBasis: textWidthBasis) {
    _handleSpecialText = hasSpecialText(text);
    addAll(children);
    extractPlaceholderSpans(text);
  }

  double get preferredLineHeight => _textPainter.preferredLineHeight;

  bool _handleSpecialText = false;

  bool hasSpecialText(InlineSpan textSpan) {
    List<InlineSpan> list = [];
    textSpanNestToArray(textSpan, list);
    if (list.length == 0) return false;

    return list.firstWhere((x) => x is FtmlInlineSpanBase,
            orElse: () => null) !=
        null;
  }

  void textSpanNestToArray(InlineSpan textSpan, List<InlineSpan> list) {
    assert(list != null);
    if (textSpan == null) return;
    list.add(textSpan);
    if (textSpan is TextSpan && textSpan.children != null)
      textSpan.children.forEach((ts) => textSpanNestToArray(ts, list));
  }

  bool get handleSpecialText => _handleSpecialText;

  InlineSpan get text => _textPainter.text;

  set text(InlineSpan value) {
    assert(value != null);
    _handleSpecialText = hasSpecialText(value);
    switch (_textPainter.text.compareTo(value)) {
      case RenderComparison.identical:
      case RenderComparison.metadata:
        return;
      case RenderComparison.paint:
        _textPainter.text = value;
        extractPlaceholderSpans(value);
        markNeedsPaint();
        markNeedsSemanticsUpdate();
        break;
      case RenderComparison.layout:
        _textPainter.text = value;
        extractPlaceholderSpans(value);
        markNeedsLayout();
        break;
    }
  }

  TextAlign get textAlign => _textPainter.textAlign;

  set textAlign(TextAlign value) {
    assert(value != null);
    if (_textPainter.textAlign == value) return;
    _textPainter.textAlign = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textPainter.textDirection;

  set textDirection(TextDirection value) {
    assert(value != null);
    if (_textPainter.textDirection == value) return;
    _textPainter.textDirection = value;
    markNeedsLayout();
  }

  @override
  TextOverflow get overFlow => _overflow;
  TextOverflow _overflow;

  set overflow(TextOverflow value) {
    assert(value != null);
    if (_overflow == TextOverflow.ellipsis) return;
    _overflow = value;
    _textPainter.ellipsis = value == TextOverflow.ellipsis ? _kEllipsis : null;

    markNeedsLayout();
  }

  @override
  bool get softWrap => _softWrap;
  bool _softWrap;

  set softWrap(bool value) {
    assert(value != null);
    if (_softWrap == value) return;
    _softWrap = value;

    markNeedsLayout();
  }

  double get textScaleFactor => _textPainter.textScaleFactor;

  set textScaleFactor(double value) {
    assert(value != null);
    if (textScaleFactor == null) return;
    textPainter.textScaleFactor = value;
    _overflowShader = null;

    markNeedsLayout();
  }

  int get maxLines => _textPainter.maxLines;

  set maxLines(int value) {
    assert(value == null || value > 0);
    if (_textPainter.maxLines == value) return;
    _textPainter.maxLines = value;
    _overflowShader = null;

    markNeedsLayout();
  }

  Locale get locale => textPainter.locale;

  set locale(Locale value) {
    if (locale == value) return;
    _textPainter.locale = value;
    _overflowShader = null;

    markNeedsLayout();
  }

  StrutStyle get strutStyle => _textPainter.strutStyle;

  set strutStyle(StrutStyle value) {
    if (strutStyle == value) return;
    _textPainter.strutStyle = value;
    _overflowShader = null;

    markNeedsLayout();
  }

  TextWidthBasis get textWidthBasis => _textPainter.textWidthBasis;

  set textWidthBasis(TextWidthBasis value) {
    assert(value != null);
    if (_textPainter.textWidthBasis == value) return;
    _textPainter.textWidthBasis = value;
    _overflowShader = null;
    markNeedsLayout();
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);
    assert(constraints != null);
    assert(constraints.debugAssertIsValid());
    _layoutTextWithConstraints(constraints);
    return _textPainter.computeDistanceToActualBaseline(baseline);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    RenderBox child = firstChild;
    int childIndex = 0;
    while (child != null &&
        childIndex < _textPainter.inlinePlaceholderBoxes.length) {
      final TextParentData textParentData = child.parentData;
      final Matrix4 transform = Matrix4.translationValues(
          textParentData.offset.dx, textParentData.offset.dy, 0.0)
        ..scale(
            textParentData.scale, textParentData.scale, textParentData.scale);
      final bool isHit = result.addWithPaintTransform(
          transform: transform,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transFormed) {
            assert(() {
              final Offset manualPosition =
                  (position - textParentData.offset) / textParentData.scale;
              return (transFormed.dx - manualPosition.dx).abs() <
                      precisionErrorTolerance &&
                  (transFormed.dy - manualPosition.dy).abs() <
                      precisionErrorTolerance;
            }());
            return child.hitTest(result, position: transFormed);
          });
      if (isHit) return true;
      child = childAfter(child);
      childIndex += 1;
    }

    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is! PointerDownEvent) return;
    _layoutTextWithConstraints(constraints);
    final Offset offset = entry.localPosition;

    final TextPosition position = _textPainter.getPositionForOffset(offset);
    final InlineSpan span = _textPainter.text.getSpanForPosition(position);
    if (span != null && span is TextSpan) span.recognizer?.addPointer(event);
  }

  void _layoutTextWithConstraints(BoxConstraints constraints) {
    layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
  }

  bool _hasVisualOverflow;
  bool _needsClipping;
  ui.Shader _overflowShader;

  @override
  void performLayout() {
    layoutChildren(constraints);
    _layoutTextWithConstraints(constraints);
    setParentData();

    final Size textSize = _textPainter.size;
    final bool textDidExceedMaxLines = _textPainter.didExceedMaxLines;
    size = constraints.constrain(textSize);

    final bool didOverflowHeight =
        size.height < textSize.height || textDidExceedMaxLines;
    final bool didOverflowWidth = size.width < textSize.width;

    _hasVisualOverflow = didOverflowHeight || didOverflowWidth;
    if (_hasVisualOverflow) {
      switch (_overflow) {
        case TextOverflow.visible:
          _needsClipping = false;
          _overflowShader = null;
          break;
        case TextOverflow.clip:
        case TextOverflow.ellipsis:
          _needsClipping = true;
          _overflowShader = null;
          break;
        case TextOverflow.fade:
          assert(textDirection != null);
          _needsClipping = true;
          final TextPainter fadeSizePainter = TextPainter(
            text: TextSpan(
              style: _textPainter.text.style,
              text: '\u2026',
            ),
            textDirection: textDirection,
            textScaleFactor: textScaleFactor,
            locale: locale,
          )..layout();
          if (didOverflowWidth) {
            double fadeEnd, fadeStart;
            switch (textDirection) {
              case TextDirection.rtl:
                fadeEnd = 0.0;
                fadeStart = fadeSizePainter.width;
                break;
              case TextDirection.ltr:
                fadeEnd = size.width;
                fadeStart = fadeEnd - fadeSizePainter.width;
                break;
            }
            _overflowShader = ui.Gradient.linear(
              Offset(fadeStart, 0.0),
              Offset(fadeEnd, 0.0),
              <Color>[const Color(0xFFFFFFFF), const Color(0x00FFFFFF)],
            );
          } else {
            final double fadeEnd = size.height;
            final double fadeStart = fadeEnd - fadeSizePainter.height / 2.0;
            _overflowShader = ui.Gradient.linear(
              Offset(0.0, fadeStart),
              Offset(0.0, fadeEnd),
              <Color>[const Color(0xFFFFFFFF), const Color(0x00FFFFFF)],
            );
          }
          break;
      }
    } else {
      _needsClipping = false;
      _overflowShader = null;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    _layoutTextWithConstraints(constraints);

    assert(() {
      if (debugRepaintTextRainbowEnabled) {
        final Paint paint = Paint()..color = debugCurrentRepaintColor.toColor();
        context.canvas.drawRect(offset & size, paint);
      }
      return true;
    }());

    _paintSpecialText(context, offset);
    _paint(context, offset);
  }

  void _paint(PaintingContext context, Offset offset) {
    if (_needsClipping) {
      final Rect bounds = offset & size;
      if (_overflowShader != null) {
        // This layer limits what the shader below blends with to be just the text
        // (as opposed to the text and its background).
        context.canvas.saveLayer(bounds, Paint());
      } else {
        context.canvas.save();
      }
      context.canvas.clipRect(bounds);
    }
    _textPainter.paint(context.canvas, offset);

    paintWidgets(context, offset);

    if (_needsClipping) {
      if (_overflowShader != null) {
        context.canvas.translate(offset.dx, offset.dy);
        final Paint paint = Paint()
          ..blendMode = BlendMode.modulate
          ..shader = _overflowShader;
        context.canvas.drawRect(Offset.zero & size, paint);
      }
      context.canvas.restore();
    }
  }

  void _paintSpecialText(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    canvas.save();

    ///move to extended text
    canvas.translate(offset.dx, offset.dy);

    ///we have move the canvas, so rect top left should be (0,0)
    final Rect rect = Offset(0.0, 0.0) & size;
    _paintSpecialTextChildren(<InlineSpan>[text], canvas, rect);
    canvas.restore();
  }

  void _paintSpecialTextChildren(
      List<InlineSpan> textSpans, Canvas canvas, Rect rect,
      {int textOffset: 0}) {
    for (InlineSpan ts in textSpans) {
      Offset topLeftOffset = getOffsetForCaret(
        TextPosition(offset: textOffset),
        rect,
      );
      //skip invalid or overflow
      if (topLeftOffset == null ||
          (textOffset != 0 && topLeftOffset == Offset.zero)) {
        return;
      }
//      if (ts is BackgroundTextSpan) {
//        var painter = ts.layout(_textPainter);
//        Rect textRect = topLeftOffset & painter.size;
//        Offset endOffset;
//        if (textRect.right > rect.right) {
//          int endTextOffset = textOffset + ts.toPlainText().length;
//          endOffset = _findEndOffset(rect, endTextOffset);
//        }
//
//        ts.paint(canvas, topLeftOffset, rect,
//            endOffset: endOffset, wholeTextPainter: _textPainter);
//      } else
      if (ts is TextSpan && ts.children != null) {
        _paintSpecialTextChildren(ts.children, canvas, rect,
            textOffset: textOffset);
      }

      textOffset += ts.toPlainText().length;
    }
  }

  /// Returns the offset at which to paint the caret.
  ///
  /// Valid only after [layout].
  Offset getOffsetForCaret(TextPosition position, Rect caretPrototype) {
    assert(!debugNeedsLayout);
    _layoutTextWithConstraints(constraints);
    return _textPainter.getOffsetForCaret(position, caretPrototype);
  }

  Size get textSize {
    assert(!debugNeedsLayout);
    return _textPainter.size;
  }

  // The offsets for each span that requires custom semantics.
  final List<int> _inlineSemanticsOffsets = <int>[];

  // Holds either [GestureRecognizer] or null (for placeholders) to generate
  // proper semnatics configurations.
  final List<dynamic> _inlineSemanticsElements = <dynamic>[];

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    _inlineSemanticsOffsets.clear();
    _inlineSemanticsElements.clear();
    final Accumulator offset = Accumulator();
    text.visitChildren((InlineSpan span) {
      span.describeSemantics(
          offset, _inlineSemanticsOffsets, _inlineSemanticsElements);
      return true;
    });
    if (_inlineSemanticsOffsets.isNotEmpty) {
      config.explicitChildNodes = true;
      config.isSemanticBoundary = true;
    } else {
      config.label = text.toPlainText();
      config.textDirection = textDirection;
    }
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return <DiagnosticsNode>[
      text.toDiagnosticsNode(
          name: 'text', style: DiagnosticsTreeStyle.transition)
    ];
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection));
    properties.add(FlagProperty('softWrap',
        value: softWrap,
        ifTrue: 'wrapping at box width',
        ifFalse: 'no wrapping except at line break characters',
        showName: true));
    properties.add(EnumProperty<TextOverflow>('overflow', overFlow));
    properties.add(
        DoubleProperty('textScaleFactor', textScaleFactor, defaultValue: 1.0));
    properties
        .add(DiagnosticsProperty<Locale>('locale', locale, defaultValue: null));
    properties.add(IntProperty('maxLines', maxLines, ifNull: 'unlimited'));
  }

  @override
  TextPainter get textPainter => _textPainter;
}

//主要用于测量
abstract class FtmlTextRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TextParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TextParentData> {
  TextPainter get textPainter;

  bool get softWrap;

  TextOverflow get overFlow;

  List<PlaceholderSpan> _placeHolderSpans;

  void extractPlaceholderSpans(InlineSpan span) {
    _placeHolderSpans = [];
    span.visitChildren((InlineSpan span) {
      if (span is PlaceholderSpan) {
        final PlaceholderSpan placeholderSpan = span;
        _placeHolderSpans.add(placeholderSpan);
      }
      return true;
    });
  }

  bool _canComputeIntrinsics() {
    for (PlaceholderSpan span in _placeHolderSpans) {
      switch (span.alignment) {
        case PlaceholderAlignment.baseline:
        case PlaceholderAlignment.aboveBaseline:
        case PlaceholderAlignment.belowBaseline:
          {
            assert(
              RenderObject.debugCheckingIntrinsics,
            );
            return false;
          }
        case PlaceholderAlignment.top:
        case PlaceholderAlignment.middle:
        case PlaceholderAlignment.bottom:
          {
            continue;
          }
      }
    }
    return true;
  }

  void _computeChildrenWidthWithMaxIntrinsics(double height) {
    RenderBox child = firstChild;

    final List<PlaceholderDimensions> placeholderDimensions =
        List<PlaceholderDimensions>(childCount);
    int childIndex = 0;

    while (child != null) {
      placeholderDimensions[childIndex] = PlaceholderDimensions(
          size: Size(child.getMaxIntrinsicWidth(height), height),
          alignment: _placeHolderSpans[childIndex].alignment,
          baseline: _placeHolderSpans[childIndex].baseline);
      child = childAfter(child);
      childIndex += 1;
    }
    this.textPainter.setPlaceholderDimensions(placeholderDimensions);
  }

  void _computeChildrenWidthWithMinIntrinsics(double height) {
    RenderBox child = firstChild;

    final List<PlaceholderDimensions> placeholderDimensions =
        List<PlaceholderDimensions>(childCount);
    int childIndex = 0;

    while (child != null) {
      final double intrinsicWidth = child.getMaxIntrinsicWidth(height);

      placeholderDimensions[childIndex] = PlaceholderDimensions(
          size:
              Size(intrinsicWidth, child.getMinIntrinsicHeight(intrinsicWidth)),
          alignment: _placeHolderSpans[childIndex].alignment,
          baseline: _placeHolderSpans[childIndex].baseline);
      child = childAfter(child);
      childIndex += 1;
    }
    this.textPainter.setPlaceholderDimensions(placeholderDimensions);
  }

  void _computeChildrenHeightWithMinIntrinsics(double width) {
    RenderBox child = firstChild;
    final List<PlaceholderDimensions> placeholderDimensions =
        List<PlaceholderDimensions>(childCount);
    int childIndex = 0;
    while (child != null) {
      //这里不一样
      final double intrinsicHeight = child.getMinIntrinsicHeight(width);
      final double intrinsicWidth = child.getMinIntrinsicWidth(intrinsicHeight);
      placeholderDimensions[childIndex] = PlaceholderDimensions(
        size: Size(intrinsicWidth, intrinsicHeight),
        alignment: _placeHolderSpans[childIndex].alignment,
        baseline: _placeHolderSpans[childIndex].baseline,
      );
      child = childAfter(child);
      childIndex += 1;
    }
    textPainter.setPlaceholderDimensions(placeholderDimensions);
  }

  void layoutChildren(BoxConstraints constraints) {
    if (childCount == 0) return;

    RenderBox child = firstChild;
    final List<PlaceholderDimensions> placeholderDimensions =
        List<PlaceholderDimensions>(childCount);
    int childIndex = 0;
    while (child != null) {
      child.layout(BoxConstraints(maxWidth: constraints.maxWidth),
          parentUsesSize: true);
      double baselineOffset;

      switch (_placeHolderSpans[childIndex].alignment) {
        case PlaceholderAlignment.baseline:
          {
            baselineOffset = child
                .getDistanceToBaseline(_placeHolderSpans[childIndex].baseline);
            break;
          }
        default:
          {
            baselineOffset = null;
            break;
          }
      }
      placeholderDimensions[childIndex] = PlaceholderDimensions(
        size: child.size,
        alignment: _placeHolderSpans[childIndex].alignment,
        baseline: _placeHolderSpans[childIndex].baseline,
        baselineOffset: baselineOffset,
      );
      child = childAfter(child);
      childIndex += 1;
    }
    textPainter.setPlaceholderDimensions(placeholderDimensions);
  }

  void setParentData() {
    RenderBox child = firstChild;
    int childIndex = 0;

    while (child != null &&
        childIndex < textPainter.inlinePlaceholderBoxes.length) {
      final TextParentData textParentData = child.parentData;

      textParentData.offset = Offset(
          textPainter.inlinePlaceholderBoxes[childIndex].left,
          textPainter.inlinePlaceholderBoxes[childIndex].top);
      textParentData.scale = textPainter.inlinePlaceholderScales[childIndex];
      child = childAfter(child);
      childIndex += 1;
    }
  }

  void layoutText(
      {double minWidth = 0.0,
      double maxWidth = double.infinity,
      double constraintWidth = double.infinity}) {
    final bool widthMatters = softWrap || overFlow == TextOverflow.ellipsis;
    textPainter.layout(
        minWidth: minWidth,
        maxWidth: widthMatters ? maxWidth : double.infinity);
  }

  void paintWidgets(PaintingContext context, Offset offset) {
    RenderBox child = firstChild;
    int childIndex = 0;

    while (child != null &&
        childIndex < textPainter.inlinePlaceholderBoxes.length) {
      final TextParentData textParentData = child.parentData;

      final double scale = textParentData.scale;
      context.pushTransform(needsCompositing, offset + textParentData.offset,
          Matrix4.diagonal3Values(scale, scale, scale),
          (PaintingContext context, Offset offset) {
        context.paintChild(child, offset);
      });

      child = childAfter(child);
      childIndex += 1;
    }
  }

  Offset getCaretOffset(TextPosition textPosition,
      {ValueChanged<double> caretHeightCallBack,
      Offset effectiveOffset,
      bool handleSpecialText: true,
      Rect caretPrototype: Rect.zero}) {
    effectiveOffset ??= Offset.zero;

    if (handleSpecialText) {
      var offset = textPosition.offset;
      if (offset <= 0) {
        offset = 1;
      }

      var boxs = textPainter.getBoxesForSelection(TextSelection(
          baseOffset: offset - 1,
          extentOffset: offset,
          affinity: textPosition.affinity));
      if (boxs.length > 0) {
        var rect = boxs.toList().last.toRect();
        caretHeightCallBack?.call(rect.height);
        if (textPosition.offset <= 0) {
          return rect.topLeft + effectiveOffset;
        } else {
          return rect.topRight + effectiveOffset;
        }
      }
    }

    final Offset caretOffset =
        textPainter.getOffsetForCaret(textPosition, caretPrototype) +
            effectiveOffset;

    return caretOffset;
  }

  double _computeIntrinsicHeight(double width) {
    if (!_canComputeIntrinsics()) {
      return 0.0;
    }
    _computeChildrenHeightWithMinIntrinsics(width);
    layoutText(minWidth: width, maxWidth: width);
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! TextParentData)
      child.parentData = TextParentData();
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (!_canComputeIntrinsics()) return 0.0;

    _computeChildrenWidthWithMinIntrinsics(height);
    layoutText();

    return textPainter.minIntrinsicWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (!_canComputeIntrinsics()) return 0.0;

    _computeChildrenWidthWithMaxIntrinsics(height);
    layoutText();
    return textPainter.maxIntrinsicWidth;
  }
}
