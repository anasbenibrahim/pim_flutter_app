import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/mood_type.dart';
import '../../../core/models/objectif_model.dart';
import '../../../core/services/api_service.dart';
import '../bloc/objectif_bloc.dart';
import '../bloc/objectif_event.dart';
import '../bloc/objectif_state.dart';
import '../widgets/objectifs_calendar.dart';
import 'add_objectif_page.dart';

class ObjectifsListPage extends StatelessWidget {
  const ObjectifsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ObjectifBloc(apiService: ApiService())
        ..add(const LoadObjectifsEvent()),
      child: const _ObjectifsListPageView(),
    );
  }
}

class _ObjectifsListPageView extends StatefulWidget {
  const _ObjectifsListPageView();

  @override
  State<_ObjectifsListPageView> createState() => _ObjectifsListPageViewState();
}

class _ObjectifsListPageViewState extends State<_ObjectifsListPageView> {
  bool _showCalendar = true;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void _navigateToAdd() async {
    final bloc = context.read<ObjectifBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlocProvider.value(
        value: bloc,
        child: const AddObjectifPage(),
      )),
    );
    if (mounted) bloc.add(const LoadObjectifsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Tracks',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.lightText,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.lightText),
        actions: [
          IconButton(
            icon: Icon(
              _showCalendar ? Icons.list_alt : Icons.calendar_month,
              size: 24.sp,
              color: AppColors.primaryPurple,
            ),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, size: 26.sp, color: AppColors.primaryPurple),
            onPressed: _navigateToAdd,
          ),
        ],
      ),
      body: BlocConsumer<ObjectifBloc, ObjectifState>(
        listener: (context, state) {
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
          if (state is ObjectifLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryPurple),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ObjectifLoaded) {
            if (state.objectifs.isEmpty) {
              return _buildEmptyState(context);
            }
            final objectifsByDate = <DateTime, List<ObjectifModel>>{};
            for (final o in state.objectifs) {
              final d = DateTime(o.objectifDate.year, o.objectifDate.month, o.objectifDate.day);
              objectifsByDate[d] = [...(objectifsByDate[d] ?? []), o];
            }
            if (_showCalendar) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ObjectifBloc>().add(const LoadObjectifsEvent());
                },
                color: AppColors.primaryPurple,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      ObjectifsCalendar(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        objectifsByDate: objectifsByDate,
                        onDaySelected: (day) => setState(() => _selectedDay = day),
                        onPageChanged: (focused) => setState(() => _focusedDay = focused),
                      ),
                      SizedBox(height: 24.h),
                      _buildSelectedDayObjectifs(
                        context,
                        objectifsByDate[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)],
                      ),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ObjectifBloc>().add(const LoadObjectifsEvent());
              },
              color: AppColors.primaryPurple,
              child: ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: state.objectifs.length,
                itemBuilder: (context, index) => _ObjectifCard(objectif: state.objectifs[index]),
              ),
            );
          }

          if (state is ObjectifInitial || state is ObjectifError) {
            return Column(
              children: [
                if (state is ObjectifError) ...[
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      state.message,
                      style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                Expanded(child: _buildEmptyState(context)),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSelectedDayObjectifs(BuildContext context, List<ObjectifModel>? objectifs) {
    if (objectifs == null || objectifs.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 20.sp, color: AppColors.lightTextSecondary),
            SizedBox(width: 8.w),
            Text(
              'No track for this date',
              style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextSecondary),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Track(s) for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.lightText,
          ),
        ),
        SizedBox(height: 12.h),
        ...objectifs.map((o) => _ObjectifCard(objectif: o)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag_outlined,
                size: 64.sp,
                color: AppColors.primaryPurple,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No tracks recorded',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Start recording your tracks to better manage your journey',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _navigateToAdd,
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text('Add a track'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectifCard extends StatelessWidget {
  final ObjectifModel objectif;

  const _ObjectifCard({required this.objectif});

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(objectif.objectifDate);
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onLongPress: () => _showDeleteDialog(context),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: _moodColor(objectif.mood).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    objectif.mood.emoji,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          objectif.mood.label,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: objectif.consumed
                                ? AppColors.error.withValues(alpha: 0.15)
                                : AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            objectif.consumed ? 'Consumed' : 'Abstinent',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: objectif.consumed ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (objectif.notes != null && objectif.notes!.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        objectif.notes!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.lightTextSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _moodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return AppColors.success;
      case MoodType.calm:
        return AppColors.primaryPurple;
      case MoodType.anxious:
        return AppColors.warning;
      case MoodType.sad:
        return AppColors.error;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: const Text(
          'Are you sure you want to delete this track?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ObjectifBloc>().add(DeleteObjectifEvent(id: objectif.id));
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
