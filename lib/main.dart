import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pimapp/features/auth/pages/get_started_page.dart';
import 'core/theme/app_colors.dart';
import 'core/services/api_service.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/navigation/pages/main_navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
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
            themeMode: ThemeMode.light,
            onGenerateRoute: AppRoutes.generateRoute,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return const MainNavigationPage();
                } else {
                  return const GetStartedPage();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
