import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ku_report_app/theme/color.dart';
import 'package:ku_report_app/services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();

  // Keep track of the selected category. Default = 'ทั้งหมด'
  String selectedCategory = 'ทั้งหมด';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppBar(
            backgroundColor: const Color(0xFFF2F5F7),
            title: const Text(
              "Dashboard",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF2F5F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Use a StreamBuilder to fetch counts for the selectedCategory
        child: StreamBuilder<Map<String, int>>(
          stream: _dashboardService.getStatusCounts(category: selectedCategory),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Extract the counts
            final counts = snapshot.data!;
            final pendingCount = counts['Pending'] ?? 0;
            final inProgressCount = counts['In Progress'] ?? 0;
            final completedCount = counts['Completed'] ?? 0;
            final canceledCount = counts['Canceled'] ?? 0;

            final total =
                pendingCount + inProgressCount + completedCount + canceledCount;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pass a callback so FilterSection can notify us
                        FilterSection(
                          onCategorySelected: (newCategory) {
                            setState(() {
                              selectedCategory = newCategory;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Summaries, pass dynamic counts
                        SummarySection(
                          pending: pendingCount,
                          inProgress: inProgressCount,
                          completed: completedCount,
                          canceled: canceledCount,
                          total: total,
                        ),
                        // const SizedBox(height: 8),

                        // Pie Chart
                        Expanded(
                          child: PieChartSection(
                            pending: pendingCount,
                            inProgress: inProgressCount,
                            completed: completedCount,
                            canceled: canceledCount,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// A modified FilterSection that can call back with the selected category
class FilterSection extends StatefulWidget {
  final void Function(String) onCategorySelected;

  const FilterSection({
    super.key,
    required this.onCategorySelected, // callback
  });

  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  int selectedIndex = 0;

  final List<String> filters = [
    'ทั้งหมด',
    'ไฟฟ้า',
    'ประปา',
    'อุปกรณ์ไฟฟ้า',
    'โครงสร้างและอาคาร',
    'ไอที',
    'ความปลอดภัย',
    'เฟอร์นิเจอร์',
    'พื้นที่ภายนอกอาคาร',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final filter = filters[index];
          return _buildFilterButton(
            filter,
            isActive: index == selectedIndex,
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              // Invoke the callback, so the parent can update
              widget.onCategorySelected(filter);
            },
          );
        }),
      ),
    );
  }

  Widget _buildFilterButton(
    String title, {
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? customGreenPrimary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class SummarySection extends StatelessWidget {
  const SummarySection({
    super.key,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.canceled,
    required this.total,
  });

  final int pending;
  final int inProgress;
  final int completed;
  final int canceled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'จำนวนปัญหาทั้งหมด $total รายการ',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 30),
        _buildStatusRow('รอรับการแก้ไข', pending, Colors.blue[400]!),
        _buildStatusRow('กำลังดำเนินการ', inProgress, Colors.orange[400]!),
        _buildStatusRow('เสร็จสิ้น', completed, Colors.green[400]!),
        _buildStatusRow('ยกเลิก', canceled, Colors.red[400]!),
      ],
    );
  }

  Widget _buildStatusRow(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            '$count รายการ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartSection extends StatelessWidget {
  const PieChartSection({
    super.key,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.canceled,
  });

  final int pending;
  final int inProgress;
  final int completed;
  final int canceled;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          // Pending
          PieChartSectionData(
            value: pending.toDouble(),
            color: Colors.blue[400]!,
            title: '$pending',
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          // In progress
          PieChartSectionData(
            value: inProgress.toDouble(),
            color: Colors.orange[400]!,
            title: '$inProgress',
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          // Completed
          PieChartSectionData(
            value: completed.toDouble(),
            color: Colors.green[400]!,
            title: '$completed',
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          // Canceled
          PieChartSectionData(
            value: canceled.toDouble(),
            color: Colors.red[400]!,
            title: '$canceled',
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
        sectionsSpace: 0,
        centerSpaceRadius: 40,
      ),
    );
  }
}
