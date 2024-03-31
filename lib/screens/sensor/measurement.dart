import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../api.dart';

class Measurement {
  final int moisture;
  final double temperature;
  final String date;
  Measurement(
      {required this.moisture, required this.temperature, required this.date,
  });
}

class _LineChart extends StatelessWidget {

  final String sensorId;
  final bool defaultView;
  final List<Measurement> measurements;

  const _LineChart({required this.defaultView, required this.sensorId, required this.measurements});

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
    if (measurements.isEmpty || index < 0 || index >= measurements.length) return const SizedBox();
    final dateString = measurements[index].date;
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
final firstDateString = measurements[0].date;
    final lastDateString = measurements[measurements.length - 1].date;

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
      for (int i = 0; i < 8 && i < measurements.length; i ++) {
        spots.add(FlSpot(i.toDouble(), measurements[i].moisture.toDouble()));
      }
    } else {
      for (int i = 0; i < measurements.length; i ++) {
        spots.add(FlSpot(i.toDouble(), measurements[i].moisture.toDouble()));
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
  List<Measurement> myMeasurements = [];

  @override
  void initState() {
    super.initState();
    defaultView = true;
    fetchData();
  }

  Api api = Api();
  
  Future<void> fetchData() async {
    api.getMeasurements(widget.sensorId).then((response) {
      if (response.success) {
        final measurementData = response.data;
        setState(() {
          myMeasurements = List<Measurement>.from(measurementData['measurements'].map((measurement) =>
            Measurement(moisture: measurement['moisture'], temperature: measurement['temperature'], date: measurement['createdAt'])));
        });
      } else {
      }
    }).catchError((error) {
      setState(() {
        print(error);
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    double latestTemperature = 0.0; 
    int latestMoisture = 0;

    if (myMeasurements.isNotEmpty) {
      latestTemperature = myMeasurements[0].temperature;
      latestMoisture = myMeasurements[0].moisture;
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
                  Text('$latestMoisture %'),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _LineChart(defaultView: defaultView, sensorId: widget.sensorId, measurements: myMeasurements)),
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
