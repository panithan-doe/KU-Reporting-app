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

class FilterSection extends StatefulWidget {
  const FilterSection({super.key});

  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  // กำหนดค่า index ของ filter ที่ active อยู่
  int selectedIndex = 0;

  // รายการ filter ทั้ง 9 อย่าง
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
        children: List.generate(
          filters.length,
          (index) => _buildFilterButton(
            filters[index],
            isActive: index == selectedIndex,
            onTap: () {
              setState(() {
                selectedIndex = index;
                // ที่นี่คุณสามารถเพิ่มฟังก์ชันการ filter ข้อมูลตาม filter ที่เลือกได้
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String title, {bool isActive = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color.fromARGB(255, 27, 179, 115) : Colors.grey.shade200,
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
              fontWeight: FontWeight.w600,
            ),
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
              fontWeight: FontWeight.bold,
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
