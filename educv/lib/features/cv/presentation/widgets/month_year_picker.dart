import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_input.dart';

class MonthYearPicker extends StatelessWidget {
  final String label;
  final String? hint;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool isRequired;

  const MonthYearPicker({
    super.key,
    required this.label,
    this.hint,
    this.value,
    required this.onChanged,
    this.isRequired = false,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showPicker(BuildContext context) {
    DateTime selectedDate = value ?? DateTime.now();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: 300,
        padding: EdgeInsets.all(AppSpacing.lg),
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
            SizedBox(height: AppSpacing.md),
            
            // Title
            Text(
              'Select Date',
              style: AppTypography.h3,
            ),
            SizedBox(height: AppSpacing.md),
            
            // Date picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.monthYear,
                initialDateTime: selectedDate,
                maximumDate: DateTime.now().add(Duration(days: 365 * 10)),
                minimumDate: DateTime(1950),
                onDateTimeChanged: (date) {
                  selectedDate = date;
                },
              ),
            ),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
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
                      onChanged(selectedDate);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Select'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: AbsorbPointer(
        child: AppInput(
          label: label,
          hint: hint ?? '',
          value: value != null ? _formatDate(value!) : null,
          isRequired: isRequired,
          suffixIcon: Icon(
            Icons.calendar_today,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}