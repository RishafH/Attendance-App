import 'dart:io';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../models/attendance_record.dart';
import '../models/monthly_summary.dart';

class PdfService {
  // Generate salary report PDF
  static Future<String?> generateSalaryReport({
    required List<AttendanceRecord> records,
    required MonthlySummary summary,
    required String employeeName,
    required String employeeId,
    String language = 'en',
  }) async {
    try {
      // Create a PDF document
      final PdfDocument document = PdfDocument();
      PdfPage page = document.pages.add();
      PdfGraphics graphics = page.graphics;
      
      // Set up fonts and colors
      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18);
      final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
      final PdfFont regularFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
      final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
      
      final PdfBrush titleBrush = PdfSolidBrush(PdfColor(0, 121, 182));
      final PdfBrush headerBrush = PdfSolidBrush(PdfColor(0, 0, 0));
      final PdfBrush textBrush = PdfSolidBrush(PdfColor(80, 80, 80));
      
      double yPosition = 30;
      const double leftMargin = 40;
      const double rightMargin = 550;

      // Get localized strings based on language
      Map<String, String> strings = _getLocalizedStrings(language);

      // Title
      graphics.drawString(
        '${strings['salaryReport']} - $employeeName',
        titleFont,
        brush: titleBrush,
        bounds: Rect.fromLTWH(leftMargin, yPosition, rightMargin - leftMargin, 25),
      );
      yPosition += 40;

      // Employee Info
      graphics.drawString(
        '${strings['employeeId']}: $employeeId',
        headerFont,
        brush: headerBrush,
        bounds: Rect.fromLTWH(leftMargin, yPosition, rightMargin - leftMargin, 20),
      );
      yPosition += 25;

      graphics.drawString(
        '${strings['generatedOn']}: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
        regularFont,
        brush: textBrush,
        bounds: Rect.fromLTWH(leftMargin, yPosition, rightMargin - leftMargin, 20),
      );
      yPosition += 30;

      // Monthly Summary
      graphics.drawString(
        '${strings['monthlyTotals']} - ${summary.monthName} ${summary.year}',
        headerFont,
        brush: headerBrush,
        bounds: Rect.fromLTWH(leftMargin, yPosition, rightMargin - leftMargin, 20),
      );
      yPosition += 25;

      // Summary details
      final summaryDetails = [
        '${strings['totalWorkingDays']}: ${summary.totalWorkingDays}',
        '${strings['presentDays']}: ${summary.presentDays}',
        '${strings['absentDays']}: ${summary.absentDays}',
        '${strings['totalBills']}: ${summary.totalBills}',
        '${strings['totalIncentives']}: ${strings['rs']} ${summary.totalIncentives.toStringAsFixed(2)}',
        '${strings['totalSalary']}: ${strings['rs']} ${summary.totalSalary.toStringAsFixed(2)}',
        '${strings['attendancePercentage']}: ${summary.attendancePercentage.toStringAsFixed(1)}%',
      ];

      for (String detail in summaryDetails) {
        graphics.drawString(
          detail,
          regularFont,
          brush: textBrush,
          bounds: Rect.fromLTWH(leftMargin + 20, yPosition, rightMargin - leftMargin - 20, 20),
        );
        yPosition += 20;
      }

      yPosition += 20;

      // Attendance Records Table
      graphics.drawString(
        strings['attendanceRecords']!,
        headerFont,
        brush: headerBrush,
        bounds: Rect.fromLTWH(leftMargin, yPosition, rightMargin - leftMargin, 20),
      );
      yPosition += 30;

      // Table headers
      final tableHeaders = [
        strings['date']!,
        strings['status']!,
        strings['startTime']!,
        strings['endTime']!,
        strings['bills']!,
        strings['salary']!,
      ];

      double columnWidth = (rightMargin - leftMargin) / tableHeaders.length;
      
      // Draw table header
      for (int i = 0; i < tableHeaders.length; i++) {
        double xPos = leftMargin + (i * columnWidth);
        graphics.drawRectangle(
          brush: PdfSolidBrush(PdfColor(240, 240, 240)),
          bounds: Rect.fromLTWH(xPos, yPosition, columnWidth, 25),
        );
        graphics.drawString(
          tableHeaders[i],
          smallFont,
          brush: headerBrush,
          bounds: Rect.fromLTWH(xPos + 5, yPosition + 5, columnWidth - 10, 20),
        );
      }
      yPosition += 25;

      // Draw table rows
      final sortedRecords = records.where((r) => 
        r.date.month == summary.month && r.date.year == summary.year
      ).toList()..sort((a, b) => a.date.compareTo(b.date));

      for (AttendanceRecord record in sortedRecords) {
        if (yPosition > 750) { // Check if we need a new page
          page = document.pages.add();
          graphics = page.graphics;
          yPosition = 30;
        }

        final rowData = [
          DateFormat('MM/dd').format(record.date),
          record.isPresent ? strings['present']! : strings['absent']!,
          record.formattedStartTime,
          record.formattedEndTime,
          record.billsCount.toString(),
          '${strings['rs']} ${record.totalSalary.toStringAsFixed(2)}',
        ];

        for (int i = 0; i < rowData.length; i++) {
          double xPos = leftMargin + (i * columnWidth);
          graphics.drawRectangle(
            pen: PdfPen(PdfColor(200, 200, 200), width: 0.5),
            bounds: Rect.fromLTWH(xPos, yPosition, columnWidth, 20),
          );
          graphics.drawString(
            rowData[i],
            smallFont,
            brush: textBrush,
            bounds: Rect.fromLTWH(xPos + 5, yPosition + 3, columnWidth - 10, 20),
          );
        }
        yPosition += 20;
      }

      // Save the PDF
      final List<int> bytes = await document.save();
      document.dispose();

      // Get the directory to save the file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'salary_report_${employeeId}_${summary.month}_${summary.year}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  // Open the generated PDF
  static Future<void> openPdf(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }

  // Get localized strings for PDF
  static Map<String, String> _getLocalizedStrings(String language) {
    switch (language) {
      case 'si':
        return {
          'salaryReport': 'වැටුප් වාර්තාව',
          'employeeId': 'සේවක අංකය',
          'generatedOn': 'ජනිත දිනය',
          'monthlyTotals': 'මාසික මුළු ගණන',
          'totalWorkingDays': 'මුළු වැඩ කරන දින',
          'presentDays': 'පැමිණි දින',
          'absentDays': 'නොපැමිණි දින',
          'totalBills': 'මුළු බිල්',
          'totalIncentives': 'මුළු දිරිදීමනා',
          'totalSalary': 'මුළු වැටුප',
          'attendancePercentage': 'පැමිණීමේ ප්‍රතිශතය',
          'attendanceRecords': 'පැමිණීමේ වාර්තා',
          'date': 'දිනය',
          'status': 'තත්ත්වය',
          'startTime': 'ආරම්භ කාලය',
          'endTime': 'අවසාන කාලය',
          'bills': 'බිල්',
          'salary': 'වැටුප',
          'present': 'පැමිණ ඇත',
          'absent': 'නොපැමිණී',
          'rs': 'රු.',
        };
      case 'ta':
        return {
          'salaryReport': 'சம்பள அறிக்கை',
          'employeeId': 'ஊழியர் அடையாள எண்',
          'generatedOn': 'உருவாக்கப்பட்ட தேதி',
          'monthlyTotals': 'மாத மொத்தம்',
          'totalWorkingDays': 'மொத்த வேலை நாட்கள்',
          'presentDays': 'வந்த நாட்கள்',
          'absentDays': 'வராத நாட்கள்',
          'totalBills': 'மொத்த பில்கள்',
          'totalIncentives': 'மொத்த ஊக்கத்தொகை',
          'totalSalary': 'மொத்த சம்பளம்',
          'attendancePercentage': 'வருகை சதவீதம்',
          'attendanceRecords': 'வருகை பதிவுகள்',
          'date': 'தேதி',
          'status': 'நிலை',
          'startTime': 'தொடக்க நேரம்',
          'endTime': 'முடிவு நேரம்',
          'bills': 'பில்கள்',
          'salary': 'சம்பளம்',
          'present': 'வந்துள்ளார்',
          'absent': 'வராமல் இருந்தார்',
          'rs': 'ரூ.',
        };
      default: // English
        return {
          'salaryReport': 'Salary Report',
          'employeeId': 'Employee ID',
          'generatedOn': 'Generated on',
          'monthlyTotals': 'Monthly Totals',
          'totalWorkingDays': 'Total Working Days',
          'presentDays': 'Present Days',
          'absentDays': 'Absent Days',
          'totalBills': 'Total Bills',
          'totalIncentives': 'Total Incentives',
          'totalSalary': 'Total Salary',
          'attendancePercentage': 'Attendance Percentage',
          'attendanceRecords': 'Attendance Records',
          'date': 'Date',
          'status': 'Status',
          'startTime': 'Start Time',
          'endTime': 'End Time',
          'bills': 'Bills',
          'salary': 'Salary',
          'present': 'Present',
          'absent': 'Absent',
          'rs': 'Rs.',
        };
    }
  }
}