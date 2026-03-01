import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/models/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/api_constants.dart';

import '../../../core/theme/app_colors.dart';

const _sapphire  = Color(0xFF0D6078);
const _indigo    = Color(0xFF022F40);
const _sunflower = Color(0xFFF8C929);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),
                    SizedBox(height: 24.h),
                    _buildGreeting(state.user.prenom, state.user.nom, state.user.profileImageUrl),
                    SizedBox(height: 20.h),

                    // Profile completion card
                    if (state.user.role == UserRole.patient && !state.user.hasCompletedAssessment)
                      _buildCompletionCard(state.user.profileCompletionScore),

                    if (state.user.role == UserRole.patient && !state.user.hasCompletedAssessment)
                      SizedBox(height: 16.h),

                    // Daily streak card
                    if (state.user.role == UserRole.patient && state.user.sobrietyDate != null)
                      _buildStreakCard(state.user.sobrietyDate!),

                    // Quick Actions
                    Text("Quick Actions", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                    SizedBox(height: 12.h),
                    _buildQuickActions(context, state.user.role),

                    SizedBox(height: 24.h),
                    
                    // Mood Journey Section
                    Text("Mood Journey", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                    SizedBox(height: 12.h),
                    _buildMoodJourneyChart(),

                    SizedBox(height: 24.h),

                    // Profile snapshot
                    _buildProfileCard(state.user.role),

                    if (state.user.role == UserRole.patient) ...[
                      SizedBox(height: 16.h),
                      _buildSobrietyCard(state.user.addiction, state.user.sobrietyDate),
                      SizedBox(height: 16.h),
                      _buildReferralCard(state.user.referralCode),
                    ],

                    if (state.user.role == UserRole.familyMember &&
                        state.user.patientNom != null) ...[
                      SizedBox(height: 16.h),
                      _buildRelatedPatientCard(state.user.patientPrenom!, state.user.patientNom!),
                    ],
                  ],
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary, strokeWidth: 2));
          }
        },
      ),
    );
  }

  // ─────────── Top Bar ───────────
  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShaderMask(
          shaderCallback: (r) => LinearGradient(colors: [theme.colorScheme.primary, AppColors.success]).createShader(r),
          child: Text('HopeUp', style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Vibration.vibrate(duration: 10, amplitude: 60);
                Navigator.of(context).pushNamed(AppRoutes.notifications);
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.getGlassColor(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.getGlassBorder(context)),
                ),
                child: Stack(
                  children: [
                    Icon(Icons.notifications_outlined, size: 20.sp, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    // Simple dot for indicator (In real app, fetch count)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: const BoxDecoration(color: AppColors.sapphire, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                Vibration.vibrate(duration: 10, amplitude: 100);
                context.read<AuthBloc>().add(const LogoutEvent());
                Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.getGlassColor(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.getGlassBorder(context)),
                ),
                child: Icon(Icons.logout_rounded, size: 20.sp, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────── Greeting ───────────
  Widget _buildGreeting(String prenom, String nom, String? profileImageUrl) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 18) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: TextStyle(fontSize: 15.sp, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w500)),
              SizedBox(height: 4.h),
              Text('$prenom $nom', style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, letterSpacing: -0.5)),
            ],
          ),
        ),
        _buildAvatar(context, profileImageUrl),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, String? profileImageUrl) {
    final theme = Theme.of(context);
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = profileImageUrl != null
        ? (profileImageUrl.startsWith('http') ? profileImageUrl : '$baseUrl$profileImageUrl')
        : null;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15), width: 2.5),
      ),
      child: CircleAvatar(
        radius: 28.r,
        backgroundColor: theme.colorScheme.surface,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child: imageUrl == null ? Icon(Icons.person_rounded, size: 28.sp, color: theme.colorScheme.primary) : null,
      ),
    );
  }

  // ─────────── Streak Card ───────────
  Widget _buildStreakCard(DateTime sobrietyDate) {
    final days = DateTime.now().difference(sobrietyDate).inDays;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, const Color(0xFF0A7A6B)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: _sunflower, size: 28.sp),
              SizedBox(width: 10.w),
              Text("Your Journey", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.85))),
            ],
          ),
          SizedBox(height: 16.h),
          Text('$days', style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
          Text('days strong', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.7))),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10.r)),
            child: Text(
              'Since ${DateFormat('MMM dd, yyyy').format(sobrietyDate)}',
              style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Quick Actions ───────────
  Widget _buildQuickActions(BuildContext context, UserRole role) {
    final theme = Theme.of(context);
    final actions = [
      _QuickAction('Journal', Icons.edit_note_rounded, AppColors.emerald),
      _QuickAction('Mood', Icons.emoji_emotions_rounded, _sunflower),
      _QuickAction('SOS', Icons.sos_rounded, AppColors.brick),
      _QuickAction('Circle', Icons.people_alt_rounded, theme.colorScheme.primary),
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              Vibration.vibrate(duration: 5, amplitude: 50);
              if (a.label == 'Mood') {
                Navigator.of(context).pushNamed(AppRoutes.assessment);
              }
            },
            child: Container(
              margin: EdgeInsets.only(right: a != actions.last ? 10.w : 0),
              padding: EdgeInsets.symmetric(vertical: 18.h),
              decoration: BoxDecoration(
                color: AppColors.getGlassColor(context),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.getGlassBorder(context)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(color: a.color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(a.icon, color: a.color, size: 22.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(a.label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────── Profile Card ───────────
  Widget _buildProfileCard(UserRole role) {
    return _card(
      context,
      icon: _getRoleIcon(role), iconColor: Theme.of(context).colorScheme.primary,
      title: 'Your Role', value: role.displayName,
    );
  }

  // ─────────── Sobriety Card ───────────
  Widget _buildSobrietyCard(String? addiction, DateTime? sobrietyDate) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: theme.brightness == Brightness.dark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Substance', style: TextStyle(fontSize: 13.sp, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                    SizedBox(height: 4.h),
                    Text(addiction ?? 'Not specified', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                  ],
                ),
              ),
              if (sobrietyDate != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(color: AppColors.emerald.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
                  child: Text('In Progress', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700, fontSize: 12.sp)),
                ),
            ],
          ),
          if (sobrietyDate != null) ...[
            SizedBox(height: 16.h),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.06), height: 1),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sober since', style: TextStyle(fontSize: 13.sp, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                Text(
                  DateFormat('MMM dd, yyyy').format(sobrietyDate),
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────── Referral Card ───────────
  Widget _buildReferralCard(String? code) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: theme.brightness == Brightness.dark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.08), shape: BoxShape.circle),
                child: Icon(Icons.share_rounded, color: theme.colorScheme.primary, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Text('Referral Code', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
            ],
          ),
          SizedBox(height: 12.h),
          Text('Share this code with people you trust.',
            style: TextStyle(fontSize: 13.sp, color: theme.colorScheme.onSurface.withOpacity(0.4), height: 1.5)),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: () {
              if (code != null) {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Code copied!'), backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(code ?? 'Loading...', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: theme.colorScheme.primary, letterSpacing: 1.5)),
                  ),
                  IconButton(
                    icon: Icon(Icons.qr_code_2_rounded, size: 24.sp, color: theme.colorScheme.primary),
                    onPressed: () {
                      if (code != null) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                            child: Padding(
                              padding: EdgeInsets.all(24.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Mon Code QR", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _indigo)),
                                  SizedBox(height: 20.h),
                                  QrImageView(
                                    data: code,
                                    version: QrVersions.auto,
                                    size: 200.w,
                                    backgroundColor: Colors.white,
                                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: _indigo),
                                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: _sapphire),
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(code, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _sapphire)),
                                  SizedBox(height: 24.h),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Fermer", style: TextStyle(color: _indigo.withOpacity(0.5))),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Icon(Icons.copy_rounded, size: 18.sp, color: theme.colorScheme.onSurface.withOpacity(0.25)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Related Patient Card ───────────
  Widget _buildRelatedPatientCard(String prenom, String nom) {
    return _card(context, icon: Icons.favorite_rounded, iconColor: AppColors.brick, title: 'Supporting', value: '$prenom $nom');
  }

  // ─────────── Common card ───────────
  Widget _card(BuildContext context, {required IconData icon, required Color iconColor, required String title, required String value}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: theme.brightness == Brightness.dark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14.r)),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.sp, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                SizedBox(height: 2.h),
                Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.patient: return Icons.person_rounded;
      case UserRole.volontaire: return Icons.volunteer_activism_rounded;
      case UserRole.familyMember: return Icons.family_restroom_rounded;
    }
  }

  Widget _buildCompletionCard(int score) {
    final theme = Theme.of(context);
    final pct = score / 100;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.assessment),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.sapphire, Color(0xFF0A8F6F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: AppColors.sapphire.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            // Circular progress ring
            SizedBox(
              width: 64.w,
              height: 64.w,
              child: CustomPaint(
                painter: _RingPainter(pct),
                child: Center(
                  child: Text('$score%', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Complete your profile', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 4.h),
                  Text('Tell us more about yourself to unlock personalized insights', style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.7))),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10.r)),
              child: Icon(Icons.arrow_forward_rounded, size: 18.sp, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodJourneyChart() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 180.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.getGlassColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.getGlassBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Weekly Trend", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.5))),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(color: AppColors.emerald.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
                child: Text("+12% improvement", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.emerald)),
              ),
            ],
          ),
          const Expanded(child: Center(child: _MoodChart())),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
              return Text(day, style: TextStyle(fontSize: 10.sp, color: theme.colorScheme.onSurface.withOpacity(0.3), fontWeight: FontWeight.w600));
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MoodChart extends StatelessWidget {
  const _MoodChart();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 100.h),
      painter: _MoodChartPainter(
        color: Theme.of(context).colorScheme.primary,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    );
  }
}

class _MoodChartPainter extends CustomPainter {
  final Color color;
  final bool isDark;
  _MoodChartPainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.85, size.height * 0.2),
      Offset(size.width, size.height * 0.3),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
        final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
        path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
    
    // Draw data points
    for (final p in points) {
      canvas.drawCircle(p, 4.w, Paint()..color = isDark ? Colors.white : color);
      canvas.drawCircle(p, 2.w, Paint()..color = isDark ? color : Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 5.0;

    // Background ring
    canvas.drawCircle(center, radius, Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth);

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -1.5708, progress * 6.2832, false, Paint()
      ..color = const Color(0xFFF8C929)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickAction(this.label, this.icon, this.color);

}
