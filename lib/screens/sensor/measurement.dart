import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme.dart';

class _LineChart extends StatelessWidget {
  const _LineChart({required this.defaultView});

  final bool defaultView;

  @override
  Widget build(BuildContext context) {
    return LineChart(defaultView ? weekView : monthView);
  }

  LineChartData get weekView => LineChartData(
        lineTouchData: touchData,
        titlesData: titlesData,
        gridData: gridData,
        borderData: borderData,
        lineBarsData: lineBarsData,
        minX: 0,
        maxX: 8,
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: 60,
              y2: 80,
              color: primary.withOpacity(0.3),
            ),
          ],
        ),
      );

  LineChartData get monthView => LineChartData(
        lineTouchData: touchData,
        titlesData: titlesData,
        gridData: gridData,
        borderData: borderData,
        lineBarsData: lineBarsData,
        minX: 0,
        maxX: 31,
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: 60,
              y2: 80,
              color: primary.withOpacity(0.3),
            ),
          ],
        ),
      );

  LineTouchData get touchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => background,
        ),
      );

  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  List<LineChartBarData> get lineBarsData => [lineChartBarData];

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('MON', style: style);
        break;
      case 2:
        text = const Text('TUE', style: style);
        break;
      case 3:
        text = const Text('WED', style: style);
        break;
      case 4:
        text = const Text('THU', style: style);
        break;
      case 5:
        text = const Text('FRI', style: style);
        break;
      case 6:
        text = const Text('SAT', style: style);
        break;
      case 7:
        text = const Text('SUN', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: text,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: accent.withOpacity(0.2), width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0.3,
        color: accent.withOpacity(0.5),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(0, 45),
          FlSpot(1, 40),
          FlSpot(2, 50),
          FlSpot(3, 60),
          FlSpot(4, 65),
          FlSpot(5, 80),
          FlSpot(6, 105),
          FlSpot(7, 85),
        ],
      );
}

class SensorChart extends StatefulWidget {
  const SensorChart({super.key});

  @override
  State<StatefulWidget> createState() => SensorChartState();
}

class SensorChartState extends State<SensorChart> {

  late bool defaultView;

  @override
  void initState() {
    super.initState();
    defaultView = true;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Column(children: <Widget>[
        Expanded(child: _LineChart(defaultView: defaultView)),
        const SizedBox(
          height: 30,
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 5),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      defaultView = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !defaultView ? primary : secondary,
                  ),
                  child: const Text('WEEK'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 30),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      defaultView = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: defaultView ? primary : secondary,
                  ),
                  child: const Text('MONTH'),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
