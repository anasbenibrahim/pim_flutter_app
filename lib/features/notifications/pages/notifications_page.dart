import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cosmic_background.dart';
// Note: NotificationModel is defined within notification_service.dart

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = NotificationService().getNotifications();
  }

  Future<void> _refresh() async {
    setState(() {
      _notificationsFuture = NotificationService().getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: FutureBuilder<List<NotificationModel>>(
                  future: _notificationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState(theme);
                    }

                    final notifications = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      color: theme.colorScheme.primary,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(notifications[index], theme);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.getGlassColor(context),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.getGlassBorder(context)),
              ),
              child: Icon(Icons.arrow_back_rounded, size: 20.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            "Notifications",
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80.sp, color: theme.colorScheme.onSurface.withOpacity(0.1)),
          SizedBox(height: 16.h),
          Text("Aucune notification", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.4))),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, ThemeData theme) {
    final isRisk = notification.type == "RISK_ALERT";
    final cardColor = isRisk ? AppColors.brick.withOpacity(0.05) : theme.colorScheme.surface;
    final iconColor = isRisk ? AppColors.brick : theme.colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isRisk ? AppColors.brick.withOpacity(0.2) : theme.colorScheme.onSurface.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isRisk ? Icons.warning_rounded : Icons.info_rounded, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (!notification.read)
                      Container(width: 8.w, height: 8.w, decoration: const BoxDecoration(color: AppColors.sapphire, shape: BoxShape.circle)),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.content,
                  style: TextStyle(fontSize: 13.sp, color: theme.colorScheme.onSurface.withOpacity(0.6), height: 1.4),
                ),
                SizedBox(height: 8.h),
                Text(
                  DateFormat('dd MMM, HH:mm').format(notification.createdAt),
                  style: TextStyle(fontSize: 11.sp, color: theme.colorScheme.onSurface.withOpacity(0.3), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
