import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
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
                    const FilterSection(),
                    const SizedBox(height: 16),
                    const SummarySection(),
                    const SizedBox(height: 24),
                    Expanded(child: PieChartSection()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterSection extends StatelessWidget {
  const FilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildFilterButton('All', isActive: true),
        _buildFilterButton('ไฟฟ้า'),
        _buildFilterButton('ถนน'),
        _buildFilterButton('อุปกรณ์'),
        _buildFilterButton('อื่นๆ'),
      ],
    );
  }

  Widget _buildFilterButton(String title, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Color.fromARGB(255, 27, 179, 115) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SummarySection extends StatelessWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'จำนวนปัญหาทั้งหมด    74 รายการ',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 30),
        _buildStatusRow('รอรับการแก้ไข', 15, Colors.red[400]!),
        _buildStatusRow('กำลังดำเนินการ', 24, Colors.orange[500]!),
        _buildStatusRow('เสร็จสิ้น', 35, Colors.green),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600, // ✅ เพิ่มความหนา
          ),
        ),
        Text(
          '$count รายการ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600, // ✅ เพิ่มความหนา
            color: color,
          ),
        ),
      ],
    ),
  );
}
}

class PieChartSection extends StatelessWidget {
  const PieChartSection({super.key});

  @override
  Widget build(BuildContext context) {
  return PieChart(
    PieChartData(
      sections: [
        PieChartSectionData(
          value: 15,
          color: Colors.red[400]!,
          title: '15',
          titleStyle: const TextStyle(
            fontWeight: FontWeight.bold, // ✅ ทำให้ตัวหนา
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          value: 24,
          color: Colors.orange[400]!,
          title: '24',
          titleStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          value: 35,
          color: Colors.green,
          title: '35',
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