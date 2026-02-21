import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/image_picker_widget.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/models/addiction_type.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// ─── HopeUp Palette ───
const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);
const _brick     = Color(0xFFF9623E);
const _sunflower = Color(0xFFF8C929);

class RegisterPatientSimplePage extends StatefulWidget {
  const RegisterPatientSimplePage({super.key});

  @override
  State<RegisterPatientSimplePage> createState() => _RegisterPatientSimplePageState();
}

class _RegisterPatientSimplePageState extends State<RegisterPatientSimplePage> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const _totalSteps = 3;

  // Step 1: Identity
  final _formKey1 = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  DateTime? _dateNaissance;
  String? _imagePath;
  bool _obscurePassword = true;

  // Step 2: Addiction Profile
  AddictionType? _addictionType;
  DateTime? _sobrietyDate;
  final Set<String> _selectedTriggers = {};
  final _otherAddictionController = TextEditingController();

  // Step 3: Motivations & Lifestyle
  final Set<String> _selectedMotivations = {};
  final Set<String> _selectedCoping = {};
  String? _activityStatus;
  String? _lifeRhythm;

  // Available options
  static const _triggerOptions = [
    'Stress', 'Ennui', 'Pression sociale', 'Problèmes familiaux',
    'Douleur physique', 'Insomnie', 'Solitude', 'Fêtes / Sorties',
    'Travail', 'Conflits relationnels', 'Anxiété', 'Autre',
  ];
  static const _motivationOptions = [
    'Santé', 'Famille', 'Travail / Études', 'Finances',
    'Estime de soi', 'Spiritualité', 'Liberté', 'Amis',
    'Relation amoureuse', 'Avenir de mes enfants', 'Autre',
  ];
  static const _copingOptions = [
    'Sport / Exercice', 'Méditation', 'Lecture', 'Musique',
    'Thérapie', 'Groupe de soutien', 'Cuisine', 'Art / Dessin',
    'Promenade nature', 'Journal intime', 'Prière', 'Autre',
  ];
  static const _activityOptions = {
    'STUDENT': 'Étudiant',
    'PROFESSIONAL': 'Professionnel',
    'UNEMPLOYED': 'Sans emploi',
    'RETIRED': 'Retraité',
  };
  static const _rhythmOptions = {
    'MORNING_PERSON': '🌅  Lève-tôt',
    'NIGHT_OWL': '🌙  Couche-tard',
    'IRREGULAR': '🔄  Irrégulier',
  };

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _otherAddictionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && !_formKey1.currentState!.validate()) return;
    if (_currentStep == 0 && _dateNaissance == null) {
      Get.snackbar('Attention', 'Veuillez sélectionner votre date de naissance',
        snackPosition: SnackPosition.TOP, backgroundColor: _brick, colorText: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), borderRadius: 12.r);
      return;
    }
    if (_currentStep < _totalSteps - 1) {
      _pageController.animateToPage(_currentStep + 1,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.animateToPage(_currentStep - 1,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }

  void _handleRegister() {
    context.read<AuthBloc>().add(
      RegisterPatientEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        age: _calculateAge(_dateNaissance!),
        dateNaissance: _dateNaissance!,
        sobrietyDate: _sobrietyDate,
        addiction: _addictionType,
        imagePath: _imagePath,
      ),
    );
  }

  Future<void> _pickDate({required bool isSobriety}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isSobriety ? DateTime.now() : DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(primary: _sapphire, onPrimary: Colors.white, surface: _linen, onSurface: _indigo),
            dialogBackgroundColor: _linen,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isSobriety) { _sobrietyDate = picked; } else { _dateNaissance = picked; }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _linen,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: _indigo, size: 20.sp), onPressed: _prevStep),
        title: Text('Inscription', style: TextStyle(color: _indigo, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          if (_currentStep > 0 && _currentStep < _totalSteps - 1)
            TextButton(
              onPressed: _nextStep,
              child: Text('Suivant', style: TextStyle(color: _sapphire, fontSize: 14.sp, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            Get.snackbar('Erreur', state.message, snackPosition: SnackPosition.TOP,
              backgroundColor: _brick, colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), borderRadius: 12.r);
          } else if (state is RegistrationOtpSentState) {
            Navigator.pushReplacementNamed(context, AppRoutes.registerOtpVerification,
              arguments: {'email': state.email, 'userRole': state.userRole, 'imagePath': state.imagePath});
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Progress bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
                child: Row(
                  children: List.generate(_totalSteps, (i) {
                    return Expanded(
                      child: Container(
                        height: 4.h,
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          color: i <= _currentStep ? _sapphire : _sapphire.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // STEP 1: Identity
  // ═══════════════════════════════════════════════════
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qui êtes-vous ?', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: _indigo, letterSpacing: -0.5)),
          SizedBox(height: 6.h),
          Text('Commençons par les informations de base.', style: TextStyle(fontSize: 14.sp, color: _indigo.withOpacity(0.5))),
          SizedBox(height: 24.h),

          // Avatar
          Center(
            child: Stack(children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _sapphire, width: 2)),
                child: ImagePickerWidget(onImageSelected: (p) => setState(() => _imagePath = p)),
              ),
              Positioned(bottom: 0, right: 0, child: Container(
                padding: EdgeInsets.all(7.w),
                decoration: const BoxDecoration(color: _sapphire, shape: BoxShape.circle),
                child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14.sp),
              )),
            ]),
          ),
          SizedBox(height: 24.h),

          Form(
            key: _formKey1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: _field('Prénom', 'Jean', _prenomController, icon: Icons.person_outline_rounded, validator: _reqV)),
                  SizedBox(width: 14.w),
                  Expanded(child: _field('Nom', 'Dupont', _nomController, validator: _reqV)),
                ]),
                SizedBox(height: 16.h),

                // Date de naissance
                Text('Date de Naissance', style: _labelStyle),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () => _pickDate(isSobriety: false),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: _boxDecoration,
                    child: Row(children: [
                      Icon(Icons.calendar_today_rounded, color: _sapphire, size: 18.sp),
                      SizedBox(width: 12.w),
                      Text(
                        _dateNaissance != null ? DateFormat('dd/MM/yyyy').format(_dateNaissance!) : 'Sélectionner',
                        style: TextStyle(fontSize: 15.sp, color: _dateNaissance != null ? _indigo : _indigo.withOpacity(0.25)),
                      ),
                    ]),
                  ),
                ),
                SizedBox(height: 16.h),
                _field('Email', 'jean.dupont@email.com', _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (!v.contains('@')) return 'Email invalide';
                  return null;
                }),
                SizedBox(height: 16.h),

                // Password
                Text('Mot de passe', style: _labelStyle),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passwordController, obscureText: _obscurePassword,
                  style: TextStyle(fontSize: 15.sp, color: _indigo),
                  decoration: _inputDeco('••••••••', Icons.lock_outline_rounded).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: _indigo.withOpacity(0.3), size: 20.sp),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) { if (v == null || v.isEmpty) return 'Requis'; if (v.length < 6) return 'Mini 6 caractères'; return null; },
                ),
                SizedBox(height: 28.h),

                _nextButton('Continuer', _nextStep),
                SizedBox(height: 16.h),
                _loginLink(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // STEP 2: Addiction Profile
  // ═══════════════════════════════════════════════════
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Votre parcours', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: _indigo, letterSpacing: -0.5)),
          SizedBox(height: 6.h),
          Text('Ces informations restent confidentielles et aident notre IA à mieux vous accompagner.',
            style: TextStyle(fontSize: 14.sp, color: _indigo.withOpacity(0.5), height: 1.5)),
          SizedBox(height: 24.h),

          // Addiction Type
          Text('Type de dépendance', style: _labelStyle),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w, runSpacing: 8.h,
            children: AddictionType.values.map((type) {
              final selected = _addictionType == type;
              return GestureDetector(
                onTap: () => setState(() => _addictionType = selected ? null : type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: selected ? _sapphire : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: selected ? _sapphire : _indigo.withOpacity(0.08)),
                  ),
                  child: Text(type.displayName, style: TextStyle(
                    fontSize: 13.sp, fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : _indigo.withOpacity(0.7),
                  )),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 22.h),

          // Sobriety Date
          Text('Date de début de sobriété (optionnel)', style: _labelStyle),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () => _pickDate(isSobriety: true),
            child: Container(
              width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: _boxDecoration,
              child: Row(children: [
                Icon(Icons.calendar_month_rounded, color: _emerald, size: 18.sp),
                SizedBox(width: 12.w),
                Text(
                  _sobrietyDate != null ? DateFormat('dd/MM/yyyy').format(_sobrietyDate!) : 'Depuis quand êtes-vous sobre ?',
                  style: TextStyle(fontSize: 14.sp, color: _sobrietyDate != null ? _indigo : _indigo.withOpacity(0.25)),
                ),
              ]),
            ),
          ),
          SizedBox(height: 22.h),

          // Triggers
          Text('Qu\'est-ce qui déclenche l\'envie ? (multi-choix)', style: _labelStyle),
          SizedBox(height: 10.h),
          _chipSelector(_triggerOptions, _selectedTriggers),
          SizedBox(height: 28.h),

          _nextButton('Continuer', _nextStep),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // STEP 3: Motivations & Lifestyle
  // ═══════════════════════════════════════════════════
  Widget _buildStep3(AuthState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vos forces', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: _indigo, letterSpacing: -0.5)),
          SizedBox(height: 6.h),
          Text('Qu\'est-ce qui vous motive et comment gérez-vous les moments difficiles ?',
            style: TextStyle(fontSize: 14.sp, color: _indigo.withOpacity(0.5), height: 1.5)),
          SizedBox(height: 24.h),

          // Motivations
          Text('Mes motivations pour la sobriété', style: _labelStyle),
          SizedBox(height: 10.h),
          _chipSelector(_motivationOptions, _selectedMotivations),
          SizedBox(height: 22.h),

          // Coping mechanisms
          Text('Mes stratégies d\'adaptation', style: _labelStyle),
          SizedBox(height: 10.h),
          _chipSelector(_copingOptions, _selectedCoping),
          SizedBox(height: 22.h),

          // Activity Status
          Text('Situation actuelle', style: _labelStyle),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w, runSpacing: 8.h,
            children: _activityOptions.entries.map((e) {
              final selected = _activityStatus == e.key;
              return GestureDetector(
                onTap: () => setState(() => _activityStatus = selected ? null : e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: selected ? _emerald : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: selected ? _emerald : _indigo.withOpacity(0.08)),
                  ),
                  child: Text(e.value, style: TextStyle(
                    fontSize: 13.sp, fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : _indigo.withOpacity(0.7),
                  )),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 22.h),

          // Life Rhythm
          Text('Mon rythme de vie', style: _labelStyle),
          SizedBox(height: 10.h),
          Column(
            children: _rhythmOptions.entries.map((e) {
              final selected = _lifeRhythm == e.key;
              return GestureDetector(
                onTap: () => setState(() => _lifeRhythm = selected ? null : e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: selected ? _sunflower.withOpacity(0.15) : Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: selected ? _sunflower : _indigo.withOpacity(0.08)),
                  ),
                  child: Text(e.value, style: TextStyle(
                    fontSize: 14.sp, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _indigo : _indigo.withOpacity(0.6),
                  )),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 28.h),

          // Register Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state is AuthLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: _sapphire, foregroundColor: Colors.white,
                disabledBackgroundColor: _sapphire.withOpacity(0.5),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0,
              ),
              child: state is AuthLoading
                  ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('S\'inscrire', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8.w), Icon(Icons.arrow_forward_rounded, size: 18.sp),
                    ]),
            ),
          ),
          SizedBox(height: 16.h),
          _loginLink(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ─── Shared Widgets ───

  Widget _chipSelector(List<String> options, Set<String> selected) {
    return Wrap(
      spacing: 8.w, runSpacing: 8.h,
      children: options.map((opt) {
        final sel = selected.contains(opt);
        return GestureDetector(
          onTap: () => setState(() { sel ? selected.remove(opt) : selected.add(opt); }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: sel ? _sapphire.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: sel ? _sapphire : _indigo.withOpacity(0.08)),
            ),
            child: Text(opt, style: TextStyle(
              fontSize: 13.sp, fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
              color: sel ? _sapphire : _indigo.withOpacity(0.6),
            )),
          ),
        );
      }).toList(),
    );
  }

  Widget _nextButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _sapphire, foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
          SizedBox(width: 8.w), Icon(Icons.arrow_forward_rounded, size: 18.sp),
        ]),
      ),
    );
  }

  Widget _loginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.login),
        child: RichText(text: TextSpan(
          text: 'Déjà un compte ? ', style: TextStyle(color: _indigo.withOpacity(0.5), fontSize: 14.sp),
          children: [TextSpan(text: 'Se Connecter', style: TextStyle(color: _sapphire, fontWeight: FontWeight.w700))],
        )),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl, {IconData? icon, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: _labelStyle),
      SizedBox(height: 8.h),
      TextFormField(
        controller: ctrl, keyboardType: keyboardType,
        style: TextStyle(fontSize: 15.sp, color: _indigo),
        decoration: _inputDeco(hint, icon), validator: validator,
      ),
    ]);
  }

  TextStyle get _labelStyle => TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _indigo.withOpacity(0.7));

  BoxDecoration get _boxDecoration => BoxDecoration(
    color: Colors.white, borderRadius: BorderRadius.circular(14.r),
    border: Border.all(color: _indigo.withOpacity(0.08)),
  );

  InputDecoration _inputDeco(String hint, [IconData? icon]) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: _indigo.withOpacity(0.25), fontSize: 15.sp),
    prefixIcon: icon != null ? Icon(icon, color: _sapphire, size: 20.sp) : null,
    filled: true, fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _indigo.withOpacity(0.08))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _indigo.withOpacity(0.08))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _sapphire, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _brick)),
  );

  String? _reqV(String? v) => (v == null || v.isEmpty) ? 'Requis' : null;
}
