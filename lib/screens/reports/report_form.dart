import 'package:flutter/material.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';

class ReportFormScreen extends StatelessWidget {
  const ReportFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GoBackAppBar(titleText: "New Report",),
      body: Center(
        child: Text('Report form'),
      ),
    );
  }
}