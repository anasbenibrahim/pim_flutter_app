import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_colors.dart';
import 'core/services/api_service.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/pages/get_started_page.dart';
import 'features/navigation/pages/main_navigation_page.dart';
import 'features/onboarding/pages/onboarding_wrapper_page.dart';
import 'features/welcome/pages/welcome_carousel_page.dart';
import 'core/controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await initializeDateFormatting('fr_FR', null);
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => AuthBloc(apiService: ApiService())
            ..add(const CheckAuthEvent()),
          child: GetMaterialApp(
            title: 'PIM App',
            debugShowCheckedModeBanner: false,
            theme: AppColors.getLightTheme(),
            darkTheme: AppColors.getDarkTheme(),
            themeMode: ThemeMode.system,
            onGenerateRoute: AppRoutes.generateRoute,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return const MainNavigationPage();
                } else if (state is AuthOnboardingRequired) {
                  return const OnboardingWrapperPage();
                } else {
                  return const WelcomeCarouselPage();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
