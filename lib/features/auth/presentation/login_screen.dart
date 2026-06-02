import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'login_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPassword = false;
  late AnimationController _animController;

  Timer? _lockTimer;
  int _lockSecondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _passCtrl.dispose();
    _lockTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startLockTimer(Duration duration) {
    _lockTimer?.cancel();
    setState(() => _lockSecondsLeft = duration.inSeconds);
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_lockSecondsLeft <= 0) {
        t.cancel();
        setState(() => _lockSecondsLeft = 0);
      } else {
        setState(() => _lockSecondsLeft--);
      }
    });
  }

  String _formatLockTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(loginViewModelProvider.notifier).signIn(
          codigo: _codigoCtrl.text.trim(),
          password: _passCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);

    ref.listen<LoginState>(loginViewModelProvider, (prev, next) {
      if (next.isAuthenticated && !(prev?.isAuthenticated ?? false)) {
        context.go('/dashboard');
      }
      if (next.isBloqueado && !(prev?.isBloqueado ?? false)) {
        _startLockTimer(next.tiempoBloqueoRestante);
      }
    });

    if (state.isCheckingSession) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(200),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: AppColors.primary,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withAlpha(230),
              const Color(0xFF8B0000),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(_animController),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_animController),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogoSection(),
                      const SizedBox(height: 48),
                      _buildFormCard(state),
                      const SizedBox(height: 40),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          AppStrings.appName,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.appSubtitle,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withAlpha(220),
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(LoginState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.isBloqueado) ...[
                  _buildLockBanner(),
                  const SizedBox(height: 24),
                ],

                Text(
                  'Ingresa tus datos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 24),

                // Código de empleado
                TextFormField(
                  controller: _codigoCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  enabled: !state.isLoading && !state.isBloqueado,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppStrings.codigoEmpleado,
                    prefixIcon: const Icon(Icons.badge_rounded),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 0,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return AppStrings.campoObligatorio;
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return 'El código debe ser numérico';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contraseña
                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_showPassword,
                  enabled: !state.isLoading && !state.isBloqueado,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: AppStrings.contrasena,
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 0,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.campoObligatorio;
                    }
                    return null;
                  },
                ),

                // Mensaje de error
                if (state.error != null && !state.isBloqueado) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.danger.withAlpha(100),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_rounded,
                          color: AppColors.danger,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Botón ingresar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(100),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading || state.isBloqueado
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.login_rounded),
                    label: Text(
                      state.isLoading ? 'Ingresando...' : AppStrings.ingresar,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    AppStrings.problemasIngresar,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.danger.withAlpha(100),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_clock_rounded,
            color: AppColors.danger,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.accesoBloquedo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Intenta nuevamente en ${_formatLockTime(_lockSecondsLeft)}',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'v1.0.0 • Caja Cusco 2026',
        style: TextStyle(
          color: Colors.white.withAlpha(180),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
