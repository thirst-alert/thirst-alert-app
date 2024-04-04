//import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../api.dart';

class Measurement {
  final double moisture;
  final double temperature;
  final String date;

  factory Measurement.fromMap(Map<String, dynamic> measurement) {
    return Measurement(
      moisture: measurement['moisture'].toDouble(),
      temperature: measurement['temperature'].toDouble(),
      date: measurement['createdAt'],
    );
  }

  Measurement(
      {required this.moisture, required this.temperature, required this.date,
  });
}

class _LineChart extends StatelessWidget {

  final String sensorId;
  final bool defaultView;
  final List<Measurement> measurementsWeek;
  final List<Measurement> measurementsMonth;

  const _LineChart({required this.defaultView, required this.sensorId, required this.measurementsMonth, required this.measurementsWeek});

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
        minY: 20,
        maxY: 120,
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
        maxX: 32,
        minY: 20,
        maxY: 120,
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

  Widget bottomTitleWidgetsWeek(double value, TitleMeta meta) {
    final index = value.toInt();
    if (measurementsWeek.isEmpty || index == 0 || index >= measurementsWeek.length) return const SizedBox();
    final dateString = measurementsWeek[index].date;
    final date = DateTime.parse(dateString);
    final day = date.day.toString();
    final month = date.month.toString();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: Text('$day/$month',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget bottomTitleWidgetsMonth(double value, TitleMeta meta) {
    if (measurementsMonth.isEmpty) return const SizedBox();
    final firstDateString = measurementsMonth[0].date;
    final lastDateString = measurementsMonth[measurementsMonth.length - 1].date;

    final firstDate = DateTime.parse(firstDateString);
    final lastDate = DateTime.parse(lastDateString);

    final fromDate = DateFormat('dd MMMM').format(firstDate);
    final toDate = DateFormat('dd MMMM').format(lastDate);

    String text = '';
    switch (value.toInt()) {
      case 16:
        text = '$fromDate - $toDate';
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  SideTitles get bottomTitles => SideTitles(    
        interval: 1,
        showTitles: true,
        getTitlesWidget: defaultView ? bottomTitleWidgetsWeek : bottomTitleWidgetsMonth
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: secondary),
        ),
      );

LineChartBarData get lineChartBarData {
    List<FlSpot> spots = [];
    if (defaultView) {
      for (int i = 0; i < measurementsWeek.length; i ++) {
        spots.add(FlSpot(i.toDouble(), measurementsWeek[i].moisture.toDouble()));
      }
    } else {
      for (int i = 0; i < measurementsMonth.length; i ++) {
        spots.add(FlSpot(i.toDouble(), measurementsMonth[i].moisture.toDouble()));
      }
    }

    return LineChartBarData(
      isCurved: true,
      curveSmoothness: 0.3,
      color: accent,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: defaultView ? true : false),
      belowBarData: BarAreaData(show: false),
      spots: spots,
    );
  }
}

class SensorChart extends StatefulWidget {

  final String sensorId;
  const SensorChart({super.key, required this.sensorId});

  @override
  State<StatefulWidget> createState() => SensorChartState();
}

class SensorChartState extends State<SensorChart> {

  late bool defaultView;
  late List<Measurement> measurementsWeek = [];
  late List<Measurement> measurementsMonth = [];

  @override
  void initState() {
    super.initState();
    defaultView = true;
    fetchDataWeek();
    fetchDataMonth();
  }

  Api api = Api();

  Future<void> fetchDataWeek() async {
    api.getMeasurementsWeek(widget.sensorId).then((response) {
      if (response.success) {
        final measurementWeekData = response.data;
        setState(() {
          measurementsWeek = List<Measurement>.from(
              measurementWeekData['measurements'].map((measurement) =>
                  Measurement.fromMap(measurement)));
        });
      } else {}
    }).catchError((error) {});
  }
  
  Future<void> fetchDataMonth() async {
    api.getMeasurementsMonth(widget.sensorId).then((response) {
      if (response.success) {
        final measurementMonthData = response.data;
        setState(() {
          measurementsMonth = List<Measurement>.from(
              measurementMonthData['measurements'].map((measurement) =>
                  Measurement.fromMap(measurement)));
        });
      } else {}
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    double latestTemperature = 0.0; 
    double latestMoisture = 0.0;

    if (measurementsWeek.isNotEmpty) {
      latestTemperature = measurementsWeek[measurementsWeek.length - 1].temperature;
      latestMoisture = measurementsWeek[measurementsWeek.length - 1].moisture;
    }

    return AspectRatio(
      aspectRatio: 1.23,
      child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Temperature'),
                  Text('$latestTemperature °C'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Moisture'),
                  Text('$latestMoisture %'), // WHAT's THIS UNIT? (% ?)
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _LineChart(defaultView: defaultView, sensorId: widget.sensorId, measurementsWeek: measurementsWeek, measurementsMonth: measurementsMonth)),
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
