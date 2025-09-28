import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/localization_provider.dart';
import '../l10n/app_localizations.dart';

class AttendanceFormPage extends StatefulWidget {
  const AttendanceFormPage({super.key});

  @override
  State<AttendanceFormPage> createState() => _AttendanceFormPageState();
}

class _AttendanceFormPageState extends State<AttendanceFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      
      // Load attendance records
      if (authProvider.currentEmployee != null) {
        attendanceProvider.loadAttendanceRecords(authProvider.currentEmployee!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.attendanceForm),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize),
            onPressed: () => context.go('/summary'),
            tooltip: l10n.summaryPage,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 8),
                    Text('Language'),
                  ],
                ),
                onTap: () => _showLanguageDialog(context, localizationProvider),
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
                onTap: () => _handleLogout(),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Employee info card
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final employee = authProvider.currentEmployee;
                  if (employee == null) return const SizedBox.shrink();
                  
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              employee.name.isNotEmpty ? employee.name[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text('${l10n.employeeId}: ${employee.id}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Attendance form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer<AttendanceProvider>(
                    builder: (context, attendanceProvider, child) {
                      return FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.attendanceForm,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            
                            // Date picker
                            FormBuilderDateTimePicker(
                              name: 'date',
                              inputType: InputType.date,
                              decoration: InputDecoration(
                                labelText: l10n.date,
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              initialValue: attendanceProvider.selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now(),
                              onChanged: (date) {
                                if (date != null) {
                                  attendanceProvider.setSelectedDate(date);
                                }
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Present/Absent switch
                            Row(
                              children: [
                                Text(l10n.status, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(l10n.absent),
                                      Switch(
                                        value: attendanceProvider.isPresent,
                                        onChanged: (value) {
                                          attendanceProvider.setPresent(value);
                                        },
                                      ),
                                      Text(l10n.present),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            if (attendanceProvider.isPresent) ...[
                              const SizedBox(height: 16),
                              
                              // Start time picker
                              Row(
                                children: [
                                  Expanded(
                                    child: FormBuilderDateTimePicker(
                                      name: 'startTime',
                                      inputType: InputType.time,
                                      decoration: InputDecoration(
                                        labelText: l10n.startTime,
                                        prefixIcon: const Icon(Icons.access_time),
                                      ),
                                      initialValue: attendanceProvider.startTime != null 
                                          ? DateTime.now().copyWith(
                                              hour: attendanceProvider.startTime!.hour,
                                              minute: attendanceProvider.startTime!.minute,
                                            )
                                          : null,
                                      onChanged: (time) {
                                        if (time != null) {
                                          attendanceProvider.setStartTime(TimeOfDay.fromDateTime(time));
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: FormBuilderDateTimePicker(
                                      name: 'endTime',
                                      inputType: InputType.time,
                                      decoration: InputDecoration(
                                        labelText: l10n.endTime,
                                        prefixIcon: const Icon(Icons.access_time_filled),
                                      ),
                                      initialValue: attendanceProvider.endTime != null 
                                          ? DateTime.now().copyWith(
                                              hour: attendanceProvider.endTime!.hour,
                                              minute: attendanceProvider.endTime!.minute,
                                            )
                                          : null,
                                      onChanged: (time) {
                                        if (time != null) {
                                          attendanceProvider.setEndTime(TimeOfDay.fromDateTime(time));
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Bills count
                              FormBuilderTextField(
                                name: 'billsCount',
                                decoration: InputDecoration(
                                  labelText: l10n.billsCount,
                                  prefixIcon: const Icon(Icons.receipt),
                                ),
                                keyboardType: TextInputType.number,
                                initialValue: attendanceProvider.billsCount.toString(),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(errorText: l10n.required),
                                  FormBuilderValidators.integer(),
                                  FormBuilderValidators.min(0),
                                ]),
                                onChanged: (value) {
                                  final count = int.tryParse(value ?? '0') ?? 0;
                                  attendanceProvider.setBillsCount(count);
                                },
                              ),
                            ],
                            
                            const SizedBox(height: 16),
                            
                            // Remarks
                            FormBuilderTextField(
                              name: 'remarks',
                              decoration: InputDecoration(
                                labelText: l10n.remarks,
                                prefixIcon: const Icon(Icons.note),
                              ),
                              maxLines: 3,
                              initialValue: attendanceProvider.remarks,
                              onChanged: (value) {
                                attendanceProvider.setRemarks(value ?? '');
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Salary calculation card
              Consumer<AttendanceProvider>(
                builder: (context, attendanceProvider, child) {
                  if (!attendanceProvider.isPresent) {
                    return const SizedBox.shrink();
                  }
                  
                  return Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Salary Calculation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSalaryRow(l10n.basePayment, attendanceProvider.basePayment, l10n.rs),
                          _buildSalaryRow(l10n.incentives, attendanceProvider.incentives, l10n.rs),
                          const Divider(),
                          _buildSalaryRow(
                            l10n.totalDailySalary,
                            attendanceProvider.totalDailySalary,
                            l10n.rs,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Save button
              Consumer<AttendanceProvider>(
                builder: (context, attendanceProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: attendanceProvider.status == AttendanceStatus.loading 
                          ? null 
                          : _handleSave,
                      child: attendanceProvider.status == AttendanceStatus.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(l10n.save),
                    ),
                  );
                },
              ),
              
              // Error/success message
              Consumer<AttendanceProvider>(
                builder: (context, attendanceProvider, child) {
                  if (attendanceProvider.errorMessage != null) {
                    return Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              attendanceProvider.errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryRow(String label, double amount, String currency, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '$currency ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      
      if (authProvider.currentEmployee == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee information not found')),
        );
        return;
      }
      
      final success = await attendanceProvider.saveAttendanceRecord(
        authProvider.currentEmployee!.id,
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.success),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _showLanguageDialog(BuildContext context, LocalizationProvider localizationProvider) {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: localizationProvider.supportedLocales.map((locale) {
              return ListTile(
                title: Text(localizationProvider.languageNames[locale.languageCode] ?? 'Unknown'),
                trailing: localizationProvider.locale == locale 
                    ? const Icon(Icons.check) 
                    : null,
                onTap: () {
                  localizationProvider.setLocale(locale);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  void _handleLogout() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    });
  }
}