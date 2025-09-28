import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/localization_provider.dart';
import '../models/attendance_record.dart';
import '../models/monthly_summary.dart';
import '../services/pdf_service.dart';
import '../l10n/app_localizations.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isExportingPdf = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.summaryPage),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/attendance'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isExportingPdf ? null : _exportToPdf,
            tooltip: l10n.exportPdf,
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, child) {
          if (attendanceProvider.status == AttendanceStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (attendanceProvider.attendanceRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRecordsFound,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final summary = attendanceProvider.getMonthlySummary(_selectedMonth, _selectedYear);
          final monthlyRecords = attendanceProvider.getRecordsForMonth(_selectedMonth, _selectedYear);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month/Year selector
                _buildMonthYearSelector(),
                const SizedBox(height: 16),
                
                // Monthly summary cards
                _buildSummaryCards(summary, l10n),
                const SizedBox(height: 16),
                
                // Daily bills chart
                if (monthlyRecords.isNotEmpty) ...[
                  _buildDailyBillsChart(monthlyRecords, l10n),
                  const SizedBox(height: 16),
                ],
                
                // Attendance records list
                _buildAttendanceRecordsList(monthlyRecords, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedMonth,
                      items: List.generate(12, (index) {
                        final month = index + 1;
                        return DropdownMenuItem(
                          value: month,
                          child: Text(DateFormat.MMMM().format(DateTime(2023, month))),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMonth = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedYear,
                      items: List.generate(5, (index) {
                        final year = DateTime.now().year - 2 + index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedYear = value;
                          });
                        }
                      },
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

  Widget _buildSummaryCards(MonthlySummary summary, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.monthlyTotals} - ${summary.monthName} ${summary.year}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              l10n.totalBills,
              summary.totalBills.toString(),
              Icons.receipt_long,
              Colors.blue,
            ),
            _buildSummaryCard(
              l10n.totalIncentives,
              '${l10n.rs} ${summary.totalIncentives.toStringAsFixed(2)}',
              Icons.star,
              Colors.orange,
            ),
            _buildSummaryCard(
              l10n.totalSalary,
              '${l10n.rs} ${summary.totalSalary.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              Colors.green,
            ),
            _buildSummaryCard(
              'Attendance',
              '${summary.attendancePercentage.toStringAsFixed(1)}%',
              Icons.event_available,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBillsChart(List<AttendanceRecord> records, AppLocalizations l10n) {
    final chartData = records.map((record) {
      return ChartData(
        DateFormat('MM/dd').format(record.date),
        record.billsCount.toDouble(),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailyBillsChart,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: l10n.date),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: l10n.billsCount),
                  minimum: 0,
                ),
                title: ChartTitle(text: l10n.dailyBillsChart),
                legend: Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: const Color(0xFF0079B6),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecordsList(List<AttendanceRecord> records, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.attendanceRecords,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    l10n.noRecordsFound,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final record = records[index];
                  return _buildAttendanceRecordItem(record, l10n);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecordItem(AttendanceRecord record, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: record.isPresent ? Colors.green : Colors.red,
            radius: 6,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${record.isPresent ? l10n.present : l10n.absent} • ${record.formattedStartTime} - ${record.formattedEndTime}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.billsCount} ${l10n.bills}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${l10n.rs} ${record.totalSalary.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf() async {
    setState(() {
      _isExportingPdf = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
      
      if (authProvider.currentEmployee == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee information not found')),
        );
        return;
      }

      final summary = attendanceProvider.getMonthlySummary(_selectedMonth, _selectedYear);
      final monthlyRecords = attendanceProvider.getRecordsForMonth(_selectedMonth, _selectedYear);

      final filePath = await PdfService.generateSalaryReport(
        records: monthlyRecords,
        summary: summary,
        employeeName: authProvider.currentEmployee!.name,
        employeeId: authProvider.currentEmployee!.id,
        language: localizationProvider.locale.languageCode,
      );

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.success),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () => PdfService.openPdf(filePath),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
        });
      }
    }
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}