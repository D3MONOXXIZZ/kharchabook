import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

/// Weekly calendar strip matching the reference design (Screen 3).
/// Displays days of the current week with day headers (Su Mo Tu We Th Fr Sa)
/// and an active high-contrast pill selector for daily expense auditing.
class WeeklyCalendarStrip extends StatelessWidget {
  final DateTime selectedMonth;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const WeeklyCalendarStrip({
    super.key,
    required this.selectedMonth,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Generate 7 days around the current week
    final baseDate = selectedDay ?? DateTime.now();
    // Start from Sunday of current week
    final sunday = baseDate.subtract(Duration(days: baseDate.weekday % 7));
    final weekDays = List.generate(7, (i) => sunday.add(Duration(days: i)));

    final monthStr = DateFormat('MMMM yyyy').format(baseDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.pastelCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.pastelBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          // Month Header with arrows: < October 2025 >
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                color: isDark ? AppColors.textSecondary : AppColors.inkBlack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onPreviousWeek,
              ),
              const SizedBox(width: 8),
              Text(
                monthStr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimary : AppColors.inkBlack,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                color: isDark ? AppColors.textSecondary : AppColors.inkBlack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onNextWeek,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Day of Week row + Day Number row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              final isSelected = selectedDay != null &&
                  selectedDay!.year == day.year &&
                  selectedDay!.month == day.month &&
                  selectedDay!.day == day.day;

              final isToday = day.year == DateTime.now().year &&
                  day.month == DateTime.now().month &&
                  day.day == DateTime.now().day;

              final dayLetter = DateFormat('E').format(day).substring(0, 2); // 'Su', 'Mo' etc

              return GestureDetector(
                onTap: () => onDaySelected(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.neonLime : AppColors.pillDark)
                        : (isToday
                            ? (isDark ? AppColors.darkCardElevated : AppColors.pastelLavender)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      // Header e.g. "Su", "Mo"
                      Text(
                        dayLetter,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (isDark ? AppColors.darkCanvas : Colors.white)
                              : (isDark ? AppColors.textSecondary : AppColors.slateMuted),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Day Number e.g. "28"
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected
                              ? (isDark ? AppColors.darkCanvas : Colors.white)
                              : (isDark ? AppColors.textPrimary : AppColors.inkBlack),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
