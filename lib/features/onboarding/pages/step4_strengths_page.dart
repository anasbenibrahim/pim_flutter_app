import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/theme/app_colors.dart';

class StrengthsPage extends StatelessWidget {
  final VoidCallback onNext;

  const StrengthsPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tes Forces",
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.getPremiumText(context)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Identifie ce qui t'aide et ce qui te freine.",
                    style: TextStyle(color: AppColors.getPremiumTextSecondary(context), fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            
            TabBar(
              indicatorColor: AppColors.primaryPurple,
              indicatorWeight: 3,
              labelColor: AppColors.getPremiumText(context),
              unselectedLabelColor: AppColors.getPremiumTextSecondary(context).withOpacity(0.5),
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
              tabs: const [
                Tab(text: "Déclencheurs"),
                Tab(text: "Coping"),
                Tab(text: "Motivation"),
              ],
            ),
            
            Expanded(
              child: TabBarView(
                children: [
                  _buildSelectionGrid(
                    context, 
                    ['Stress', 'Solitude', 'Fête', 'Ennui', 'Colère', 'Fatigue'], 
                    (state) => state.triggers,
                    (item) => TriggerToggled(item)
                  ),
                  _buildSelectionGrid(
                    context, 
                    ['Sport', 'Musique', 'Méditation', 'Ami', 'Lire', 'Dormir'], 
                    (state) => state.copingMechanisms,
                    (item) => CopingMechanismToggled(item)
                  ),
                  _buildSelectionGrid(
                    context, 
                    ['Santé', 'Famille', 'Argent', 'Travail', 'Estime', 'Liberté'], 
                    (state) => state.motivations,
                    (item) => MotivationToggled(item)
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: Text(
                    "Suivant", 
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionGrid(
    BuildContext context, 
    List<String> items, 
    List<String> Function(OnboardingState) selector,
    OnboardingEvent Function(String) eventFactory
  ) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final selectedItems = selector(state);
        return GridView.builder(
          padding: EdgeInsets.all(24.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = selectedItems.contains(item);
            return GestureDetector(
              onTap: () => context.read<OnboardingBloc>().add(eventFactory(item)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryPurple.withOpacity(0.2) : AppColors.getGlassColor(context).withOpacity(0.05),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryPurple : AppColors.getGlassBorder(context),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  item,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primaryPurple) : AppColors.getPremiumTextSecondary(context),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

