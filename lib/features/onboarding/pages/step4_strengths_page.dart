import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _brick     = Color(0xFFF9623E);
const _emerald   = Color(0xFF46C67D);
const _sunflower = Color(0xFFF8C929);

class StrengthsPage extends StatelessWidget {
  final VoidCallback onNext;

  const StrengthsPage({super.key, required this.onNext});

  static const _triggers = ['Stress', 'Solitude', 'Fête', 'Ennui', 'Colère', 'Fatigue', 'Pression sociale', 'Insomnie'];
  static const _coping = ['Sport', 'Musique', 'Méditation', 'Ami', 'Lire', 'Dormir', 'Prière', 'Nature'];
  static const _motivations = ['Santé', 'Famille', 'Argent', 'Travail', 'Estime', 'Liberté', 'Avenir enfants', 'Spiritualité'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _linen,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(28.w, 16.h, 28.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tes Forces", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: _indigo, letterSpacing: -0.5)),
                  SizedBox(height: 6.h),
                  Text("Identifie ce qui t'aide et ce qui te freine.",
                    style: TextStyle(color: _indigo.withOpacity(0.5), fontSize: 14.sp)),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Tab Bar
            TabBar(
              indicatorColor: _sapphire,
              indicatorWeight: 3,
              labelColor: _indigo,
              unselectedLabelColor: _indigo.withOpacity(0.35),
              dividerColor: _indigo.withOpacity(0.06),
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
              tabs: const [
                Tab(text: "Déclencheurs"),
                Tab(text: "Coping"),
                Tab(text: "Motivation"),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildGrid(context, _triggers, (s) => s.triggers, (item) => TriggerToggled(item), _brick),
                  _buildGrid(context, _coping, (s) => s.copingMechanisms, (item) => CopingMechanismToggled(item), _emerald),
                  _buildGrid(context, _motivations, (s) => s.motivations, (item) => MotivationToggled(item), _sunflower),
                ],
              ),
            ),

            // Button
            Padding(
              padding: EdgeInsets.fromLTRB(28.w, 8.h, 28.w, 28.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sapphire, foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0,
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Suivant", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    SizedBox(width: 8.w), Icon(Icons.arrow_forward_rounded, size: 18.sp),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<String> items,
    List<String> Function(OnboardingState) selector,
    OnboardingEvent Function(String) eventFactory,
    Color accentColor,
  ) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final selectedItems = selector(state);
        return GridView.builder(
          padding: EdgeInsets.all(24.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 2.4,
            crossAxisSpacing: 12.w, mainAxisSpacing: 12.h,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final selected = selectedItems.contains(item);
            return GestureDetector(
              onTap: () => context.read<OnboardingBloc>().add(eventFactory(item)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? accentColor.withOpacity(0.12) : Colors.white,
                  border: Border.all(color: selected ? accentColor : _indigo.withOpacity(0.08), width: selected ? 2 : 1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  item,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _indigo : _indigo.withOpacity(0.5),
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
