import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AttendanceOverviewScreen extends StatefulWidget {
  @override
  _AttendanceOverviewScreenState createState() =>
      _AttendanceOverviewScreenState();
}

class _AttendanceOverviewScreenState extends State<AttendanceOverviewScreen> {
  late List<ChartData> chartData;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Attendance Trends'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Overall Class Attendance
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Class Attendance',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SfCircularChart(
                      title: ChartTitle(text: 'This Week'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: _tooltipBehavior,
                      series: <CircularSeries<ChartData, String>>[
                        DoughnutSeries<ChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          enableTooltip: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Individual Student Attendance Trends
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Individual Student Attendance Trends',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SfCartesianChart(
                      title: ChartTitle(text: 'Last 30 Days'),
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis:
                          NumericAxis(minimum: 0, maximum: 100, interval: 20),
                      tooltipBehavior: _tooltipBehavior,
                      series: <CartesianSeries<ChartData, String>>[
                        LineSeries<ChartData, String>(
                          dataSource: [
                            ChartData('Week 1', 80),
                            ChartData('Week 2', 90),
                            ChartData('Week 3', 75),
                            ChartData('Week 4', 95),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          enableTooltip: true,
                          markerSettings: MarkerSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Attendance Statistics
            Card(
              elevation: 2.0,
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Statistics',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text('Average Attendance: 85%'),
                    Text('Highest Attendance: 95% (Week 4)'),
                    Text('Lowest Attendance: 75% (Week 3)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> getChartData() {
    return [
      ChartData('Present', 85),
      ChartData('Absent', 15),
    ];
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
