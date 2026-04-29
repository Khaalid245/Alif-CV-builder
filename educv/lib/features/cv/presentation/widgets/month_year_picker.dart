import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_input.dart';

class MonthYearPicker extends StatelessWidget {
  final String label;
  final String? hint;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onChanged;
  final String? Function(String?)? validator;

  const MonthYearPicker({
    super.key,
    required this.label,
    this.hint,
    this.selectedDate,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: selectedDate != null 
          ? DateFormat('MMM yyyy').format(selectedDate!)
          : '',
    );

    return AppInput(
      label: label,
      hint: hint ?? 'Select month and year',
      controller: controller,
      enabled: false,
      validator: validator,
      suffixIcon: const Icon(
        Icons.calendar_month,
        color: AppColors.textSecondary,
      ),
      onTap: () => _showMonthYearPicker(context),
    );
  }

  void _showMonthYearPicker(BuildContext context) {
    DateTime initialDate = selectedDate ?? DateTime.now();
    DateTime tempDate = initialDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Title
              Text(
                'Select Month & Year',
                style: AppTypography.h3,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Date picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.monthYear,
                  initialDateTime: initialDate,
                  minimumYear: 1950,
                  maximumYear: DateTime.now().year + 10,
                  onDateTimeChanged: (DateTime date) {
                    tempDate = date;
                  },
                ),
              ),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onChanged(tempDate);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                      child: const Text('Select'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}