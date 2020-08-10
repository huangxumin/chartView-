import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';


class ChartViewGroup extends StatefulWidget {
  @override
  _State createState() => _State();

  //集合
  List values=[10,20,30,10,50,60,10];

  ChartViewGroup(List<int> values) {
    if (values != null && values.isNotEmpty) {
      this.values = values;
    }
  }
}

class _State extends State<ChartViewGroup> {



  Offset _down;
  Offset _update;

  //实际已经位移
  double realScroll = 0.0;
  double maxScroll = 0.0;
  double _scroll = 0;


  @override
  Widget build(BuildContext context) {
    return

      GestureDetector(
        onHorizontalDragStart: (details) {
          _down = details.localPosition;
        },
        onHorizontalDragUpdate: (details) {
//              setState(() { });
          _update = details.localPosition;
          //得出横向滑动距离
          if (_update != null &&
              _update.dx != null &&
              _down.dx != null &&
              _down != null) {
            _scroll = _update.dx - _down.dx;
            realScroll += _scroll;
            _down = _update;
            if (realScroll > 0) {
              //已经到达第一个柱形图，禁止滑动
              realScroll = 0.0;
            }
            if (realScroll.abs() > maxScroll) {
              //已经到达最后柱形图，禁止滑动
              realScroll = -maxScroll;
            }
          }
          setState(() {

          });
        },
        child: CustomPaint(
                  painter: ChartView(realScroll, widget.values, (value) {
                    //最大支持得滑动距离
                    if (maxScroll == 0 && value != null) {
                      maxScroll = value;
                    }
                  })),
      );
//        });
  }
}

typedef AddCallback = void Function();

class ChartView extends CustomPainter {
  double fontSize = 12.0;
  double textWidth = 15.0;
  int maxValue = 0;
  String maxValueStr = "0";

  //坐标轴䣌一些参数

  ui.Paragraph xAxisTopText;
  ui.Paragraph xAxisBottomText;
  Offset xAxisTop;
  Offset yAxisEnd;
  Offset axisStart;
  final xyPaint = Paint();
  final whitePaint = Paint();
  final whitePaintEnd = Paint();
  final blackPaintEnd = Paint();

  double axisMarginStart = 37.0;
  double axisMarginTop = 16.0;
  double axisMarginBottom = 49.0;
  double axisMarginEnd = 58.0;

  //柱形图的一些参数配置
  int marginStart = 14;
  double chartWidth = 32;
  int chartMargin = 35;
  double chartPlace = 0;

  //第一次绘制得时候当前x轴最终得长度
  double firstChartEndWidth = 0;
  final chartPaint = Paint();

  var style = ui.ParagraphStyle(
    textAlign: TextAlign.center,
    fontSize: 12,
    textDirection: TextDirection.ltr,
    maxLines: 1,
  );

  //集合
  List values;

  double realScroll = 0.0;

  bool isDraw = false;
  ValueChanged voidCallback;
  ValueChanged maxScrollCallback;

  ChartView(this.realScroll, this.values, this.maxScrollCallback) {
    //柱形图起始位置

    xyPaint.color = Color(0xff333333);
    whitePaint.color = Color(0xffffffff);
    whitePaintEnd.color = Color(0xffffffff);
    blackPaintEnd.color = Color(0xff000000);
//    chartPaint.color = Color(0xFFFBC02D);
    chartPaint.strokeWidth = (chartWidth);
    whitePaint.strokeWidth = (axisMarginStart);
    whitePaintEnd.strokeWidth = (axisMarginEnd);
    blackPaintEnd.strokeWidth = 1;

    int cacheMaxValue = 0;
    for (int i = 0; i < values.length; i++) {
      if (values[i] > cacheMaxValue) {
        cacheMaxValue = values[i];
      }
    }

    maxValue = getMaxValue(cacheMaxValue);
    print("maxValue==" + maxValue.toString());
    maxValueStr = getConvertedNumber(maxValue);
    print("maxValueStr==" + maxValueStr.toString());



    //下面是文字配置
    ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      style,
    )
      ..pushStyle(
        ui.TextStyle(
            color: Color(0xff999999), textBaseline: ui.TextBaseline.alphabetic),
      )
      ..addText(maxValueStr.toString()); //..级联操作符

    var paragraphBuilder1 = ui.ParagraphBuilder(
      style,
    )
      ..pushStyle(
        ui.TextStyle(
            color: Color(0xff999999), textBaseline: ui.TextBaseline.alphabetic),
      );

    xAxisTopText = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: axisMarginStart));

    paragraphBuilder1.addText("0");

    xAxisBottomText = paragraphBuilder1.build()
      ..layout(ui.ParagraphConstraints(width: axisMarginStart));
  }

  ui.Paragraph getChartTopText(String string) {
    var paragraphBuilder = ui.ParagraphBuilder(
      style,
    )
      ..pushStyle(
        ui.TextStyle(
            color: Color(0xff999999), textBaseline: ui.TextBaseline.alphabetic),
      );

    paragraphBuilder.addText(string);
    return paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: chartWidth));
  }

  @override
  void paint(Canvas canvas, Size size) {

    var height = size.height;
    var width = size.width;

    //计算高度
    var axisHeight = height - axisMarginBottom - axisMarginTop;
    var scale = axisHeight / maxValue;


    chartPlace = marginStart + axisMarginStart + realScroll;

    //绘制梯形图
    print("chartPlace==" + chartPlace.toString());


    for (int i = 0; i < values.length; i++) {
      if (i != 0) {
        chartPlace += chartWidth;
        chartPlace += chartMargin;
      }

      if (i == values.length - 1) {
        //最后一个，记录
        maxScrollCallback.call(
            chartPlace + chartWidth + chartMargin - (width - axisMarginEnd));
      }

      if ((chartPlace + chartWidth) < axisMarginStart) {
        //此图已经完全离开显示区域，不进行绘制
        continue;
      }

      if ((chartPlace) > (width - axisMarginEnd)) {
        //此图已经完全离开显示区域，不进行绘制
        continue;
      }

      Offset x;
      Offset y;

      if (chartPlace < (width - axisMarginEnd) &&
          (chartPlace + chartWidth) > (width - axisMarginEnd)) {
        //此图已经部分进入显示区域
        var cacheChartWidth = (width - axisMarginEnd) - chartPlace;
        chartPaint.strokeWidth = cacheChartWidth;

        x = Offset((width - axisMarginEnd) - cacheChartWidth / 2,
            height - axisMarginBottom);

        y = Offset((width - axisMarginEnd) - cacheChartWidth / 2,
            axisHeight + axisMarginTop - scale * values[i]);
      } else if (chartPlace < axisMarginStart) {
        //此图已经部分离开显示区域
        //剩余长度
        var cacheChartWidth = chartPlace + chartWidth - axisMarginStart;
        chartPaint.strokeWidth = cacheChartWidth;

        x = Offset(
            axisMarginStart + cacheChartWidth / 2, height - axisMarginBottom);

        y = Offset(axisMarginStart + cacheChartWidth / 2,
            axisHeight + axisMarginTop - scale * values[i]);
      } else {
        chartPaint.strokeWidth = chartWidth;

        x = Offset(chartPlace + chartWidth / 2, height - axisMarginBottom);

        y = Offset(chartPlace + chartWidth / 2,
            axisHeight + axisMarginTop - scale * values[i]);
      }

      chartPaint.shader =
          ui.Gradient.linear(x, y, [Color(0x1AFBC02D), Color(0xFFFBC02D)]);

      canvas.drawLine(x, y, chartPaint);

      var charTxt = getChartTopText(getConvertedNumber(values[i]));
      var chartY = Offset(chartPlace + chartWidth / 2 - charTxt.width / 2,
          axisHeight + axisMarginTop - scale * values[i] - charTxt.height);
      canvas.drawParagraph(charTxt, chartY);
    }

    //先画挡板--挡住文字
    var top = Offset(axisMarginStart / 2, 0);
    var bottom = Offset(axisMarginStart / 2, height);

    var topEnd = Offset((width + (width - axisMarginEnd)) / 2, 0);
    var bottomEnd = Offset((width + (width - axisMarginEnd)) / 2, height);

    canvas.drawLine(top, bottom, whitePaint);
    canvas.drawLine(topEnd, bottomEnd, whitePaintEnd);

    //x轴
    xAxisTop = Offset(axisMarginStart, axisMarginTop);
    axisStart = Offset(axisMarginStart, height - axisMarginBottom);
    canvas.drawLine(axisStart, xAxisTop, xyPaint);

    //Y轴
    yAxisEnd = Offset(width - axisMarginEnd, height - axisMarginBottom);
    canvas.drawLine(axisStart, yAxisEnd, xyPaint);

    //坐标轴文字
    canvas.drawParagraph(xAxisTopText,
        Offset(axisMarginStart/2 - xAxisTopText.width/2, axisMarginTop));

    canvas.drawParagraph(
        xAxisBottomText,
        Offset(axisMarginStart/2 - xAxisBottomText.width/2 ,
            height - axisMarginBottom - xAxisBottomText.height));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }


  int getMaxValue(int valueMaxScale) {
    //没找到幂运算
    var unit = 10;
    for (int i = 0; i < valueMaxScale.toString().length - 2; i++) {
      unit *= 10;
    }
//   var unit = (10.modPow(valueMaxScale.toString().length, 1) / 10);
    //集合中最大值的上一个单位
    return ((valueMaxScale ~/ (unit) + 1) * unit).toInt();
  }

  String getConvertedNumber(int number) {
    if (number < 10000) {
      return number.toString();
    } else if (number < 1000000) {
      var converted = (number / 10000).toStringAsFixed(1).toString();
      if (converted.endsWith(".0")) {
        converted = converted.replaceAll(".0", "");
      }
      return converted + "万";
    } else if (number < 100100100) {
      var converted = number / 10000;
      return converted.toString() + "万";
    } else {
      var converted =  (number / 100000000).toStringAsFixed(2).toString();
      if (converted.endsWith(".00")) {
        converted = converted.replaceAll(".00", "");
      }
      return converted + "亿";
    }
  }

}
