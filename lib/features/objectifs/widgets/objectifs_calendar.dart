import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/objectif_model.dart';
import '../../../core/models/mood_type.dart';

/// Calendrier mensuel style screenshot : mois avec dropdown à gauche, chevrons à droite,
/// emojis d'humeur sous les dates.
class ObjectifsCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<ObjectifModel>> objectifsByDate;
  final void Function(DateTime day) onDaySelected;
  final void Function(DateTime focused) onPageChanged;
  final DateTime? maxSelectableDay;

  const ObjectifsCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.objectifsByDate,
    required this.onDaySelected,
    required this.onPageChanged,
    this.maxSelectableDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header personnalisé : "October ▼" à gauche, "< >" à droite
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _showMonthPicker(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.yMMMM('en').format(focusedDay),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightText,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.lightText, size: 24.sp),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    final prev = DateTime(focusedDay.year, focusedDay.month - 1);
                    onPageChanged(prev);
                  },
                  icon: Icon(Icons.chevron_left, color: AppColors.lightText, size: 28.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: () {
                    final next = DateTime(focusedDay.year, focusedDay.month + 1);
                    if (maxSelectableDay != null &&
                        (next.year > maxSelectableDay!.year ||
                            (next.year == maxSelectableDay!.year &&
                                next.month > maxSelectableDay!.month))) {
                      return;
                    }
                    onPageChanged(next);
                  },
                  icon: Icon(
                    Icons.chevron_right,
                    color: (maxSelectableDay != null &&
                            (focusedDay.year > maxSelectableDay!.year ||
                                (focusedDay.year == maxSelectableDay!.year &&
                                    focusedDay.month >= maxSelectableDay!.month)))
                        ? Colors.grey
                        : AppColors.lightText,
                    size: 28.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          TableCalendar<ObjectifModel>(
            firstDay: DateTime(2020),
            lastDay: maxSelectableDay ?? DateTime.now().add(const Duration(days: 365)),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            rowHeight: 48.h,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                final objectifs = events.cast<ObjectifModel>();
                final mood = objectifs.first.mood;
                return Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    mood.emoji,
                    style: TextStyle(fontSize: 18.sp),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextSecondary,
              ),
              weekendStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextSecondary,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
              weekendTextStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.lightText,
              ),
              defaultTextStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.lightText,
              ),
              outsideTextStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.lightTextSecondary.withValues(alpha: 0.6),
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF4FC3F7),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPurple,
              ),
              markerDecoration: BoxDecoration(color: Colors.transparent),
              markerSize: 0,
              cellMargin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
            ),
            eventLoader: (day) {
              final normalized = DateTime(day.year, day.month, day.day);
              final list = objectifsByDate[normalized];
              return list ?? [];
            },
            onDaySelected: (selected, focused) {
              onDaySelected(selected);
              onPageChanged(focused);
            },
            onPageChanged: onPageChanged,
            locale: 'en',
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: 300.h,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'Choose month',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightText,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = DateTime(focusedDay.year, index + 1);
                      final isFuture = maxSelectableDay != null &&
                          (month.year > maxSelectableDay!.year ||
                              (month.year == maxSelectableDay!.year &&
                                  month.month > maxSelectableDay!.month));
                      return ListTile(
                        title: Text(
                          DateFormat.yMMMM('en').format(month),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isFuture
                                ? Colors.grey
                                : (month.year == focusedDay.year && month.month == focusedDay.month)
                                    ? AppColors.primaryPurple
                                    : AppColors.lightText,
                          ),
                        ),
                        onTap: isFuture
                            ? null
                            : () {
                                onPageChanged(month);
                                Navigator.pop(ctx);
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
