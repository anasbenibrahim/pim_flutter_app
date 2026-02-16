import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/mood_type.dart';
import '../../../core/models/objectif_model.dart';
import '../bloc/objectif_bloc.dart';
import '../bloc/objectif_event.dart';
import '../bloc/objectif_state.dart';
import '../widgets/objectifs_calendar.dart';

class AddObjectifPage extends StatefulWidget {
  const AddObjectifPage({super.key});

  @override
  State<AddObjectifPage> createState() => _AddObjectifPageState();
}

class _AddObjectifPageState extends State<AddObjectifPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  MoodType _selectedMood = MoodType.calm;
  bool _consumed = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'New Track',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.lightText,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.lightText),
      ),
      body: BlocConsumer<ObjectifBloc, ObjectifState>(
        listenWhen: (previous, current) {
          // Snackbar succès uniquement quand on vient de créer (ObjectifCreating -> ObjectifLoaded)
          if (previous is ObjectifCreating && current is ObjectifLoaded) return true;
          if (current is ObjectifError) return true;
          return false;
        },
        listener: (context, state) {
          if (state is ObjectifLoaded) {
            Get.snackbar(
              'Success',
              'Track saved successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.success,
              colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              borderRadius: 8.r,
            );
            Navigator.pop(context);
          }
          if (state is ObjectifError) {
            Get.snackbar(
              'Error',
              state.message,
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.error,
              colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              borderRadius: 8.r,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ObjectifCreating;
          final objectifsByDate = <DateTime, List<ObjectifModel>>{};
          if (state is ObjectifLoaded) {
            for (final o in state.objectifs) {
              final d = DateTime(o.objectifDate.year, o.objectifDate.month, o.objectifDate.day);
              objectifsByDate[d] = [...(objectifsByDate[d] ?? []), o];
            }
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Calendrier pour sélectionner la date (comme la page Suivi)
                  _SectionTitle(title: 'Date'),
                  SizedBox(height: 12.h),
                  ObjectifsCalendar(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDate,
                    objectifsByDate: objectifsByDate,
                    onDaySelected: (day) => setState(() => _selectedDate = day),
                    onPageChanged: (focused) => setState(() => _focusedDay = focused),
                    maxSelectableDay: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                  ),
                  SizedBox(height: 28.h),
                  // Mood selector with 4 emojis
                  _SectionTitle(title: 'How do you feel?'),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: MoodType.values.map((mood) {
                      final isSelected = _selectedMood == mood;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = mood),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryPurple.withValues(alpha: 0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryPurple : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.2), blurRadius: 8)]
                                : [],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(mood.emoji, style: TextStyle(fontSize: 28.sp)),
                              SizedBox(height: 4.h),
                              Text(
                                mood.label,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? AppColors.primaryPurple : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 28.h),
                  // Consumed toggle
                  _SectionTitle(title: 'Did you consume today?'),
                  SizedBox(height: 12.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ConsumedOption(
                            label: 'No, abstinent',
                            icon: Icons.check_circle_outline,
                            color: AppColors.success,
                            isSelected: !_consumed,
                            onTap: () => setState(() => _consumed = false),
                          ),
                        ),
                        Expanded(
                          child: _ConsumedOption(
                            label: 'Yes, consumed',
                            icon: Icons.cancel_outlined,
                            color: AppColors.error,
                            isSelected: _consumed,
                            onTap: () => setState(() => _consumed = true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),
                  // Notes (optional)
                  _SectionTitle(title: 'Notes (optional)'),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add notes for this day...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  // Submit button
                  SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ObjectifBloc>().add(CreateObjectifEvent(
                                      objectifDate: _selectedDate,
                                      mood: _selectedMood,
                                      consumed: _consumed,
                                      notes: _notesController.text.trim().isEmpty
                                          ? null
                                          : _notesController.text.trim(),
                                    ));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Save', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
      ),
    );
  }
}

class _ConsumedOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConsumedOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
