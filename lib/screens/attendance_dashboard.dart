import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AttendanceDashboard extends StatefulWidget {
  const AttendanceDashboard({super.key});

  @override
  _AttendanceDashboardState createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  String _selectedPeriod = 'monthly';

  final List<ChartData> _chartData = [
    ChartData('Jan', 92, 88, 85),
    ChartData('Feb', 88, 85, 85),
    ChartData('Mar', 95, 87, 85),
    ChartData('Apr', 85, 84, 85),
    ChartData('May', 89, 86, 85),
  ];

  final List<SubjectData> _subjectData = [
    SubjectData('Data Analytics', 95),
    SubjectData('Operating System', 88),
    SubjectData('Data Structure', 76),
    SubjectData('Flutter', 85),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Attendance Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Monthly Trend Line Chart
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text('Monthly Attendance Trends'),
                  ),
                  SizedBox(
                    height: 250,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(minimum: 0, maximum: 100),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<ChartData, String>>[
                        LineSeries<ChartData, String>(
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.month,
                          yValueMapper: (ChartData data, _) => data.attendance,
                          name: 'Your Attendance',
                          color: Colors.blue,
                        ),
                        LineSeries<ChartData, String>(
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.month,
                          yValueMapper: (ChartData data, _) =>
                              data.avgClassAttendance,
                          name: 'Class Average',
                          color: Colors.purple,
                        ),
                        LineSeries<ChartData, String>(
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.month,
                          yValueMapper: (ChartData data, _) => data.target,
                          name: 'Target',
                          color: Colors.red,
                          dashArray: [5, 5],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Subject-wise Attendance Bar Chart
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text('Subject-wise Attendance'),
                  ),
                  SizedBox(
                    height: 250,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(minimum: 0, maximum: 100),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<SubjectData, String>>[
                        BarSeries<SubjectData, String>(
                          dataSource: _subjectData,
                          xValueMapper: (SubjectData data, _) => data.subject,
                          yValueMapper: (SubjectData data, _) =>
                              data.attendance,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Weekly Pattern Heatmap
            Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text(
                      'Weekly Attendance Pattern',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 5,
                      shrinkWrap: true,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildAttendanceCell('Mon', 90, Colors.green),
                        _buildAttendanceCell('Tue', 80, Colors.lightGreen),
                        _buildAttendanceCell('Wed', 75, Colors.orange),
                        _buildAttendanceCell('Thu', 50, Colors.red),
                        _buildAttendanceCell('Fri', 100, Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCell(String day, double percentage, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.month, this.attendance, this.avgClassAttendance, this.target);
  final String month;
  final double attendance;
  final double avgClassAttendance;
  final double target;
}

class SubjectData {
  SubjectData(this.subject, this.attendance);
  final String subject;
  final double attendance;
}
