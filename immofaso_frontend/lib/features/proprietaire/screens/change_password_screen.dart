import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/auth_text_field.dart';

enum _Step { telephone, otpAndNewPassword }

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _telephoneFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _telephoneController = TextEditingController();
  final _pinController = PinInputController();
  final _newPasswordController = TextEditingController();

  _Step _step = _Step.telephone;
  bool _isSubmitting = false;
  String? _devOtpCode;

  @override
  void dispose() {
    _telephoneController.dispose();
    _pinController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_telephoneFormKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final otpCode = await ref.read(authRepositoryProvider).forgotPassword(
            telephone: _telephoneController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _devOtpCode = otpCode;
        _step = _Step.otpAndNewPassword;
      });
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authRepositoryProvider).changerPassword(
            telephone: _telephoneController.text.trim(),
            otpCode: _pinController.text,
            newPassword: _newPasswordController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe réinitialisé. Connectez-vous.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      _pinController.triggerError();
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _copyOtp() {
    final code = _devOtpCode;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copié.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _step == _Step.telephone ? _buildTelephoneStep() : _buildResetStep(),
        ),
      ),
    );
  }

  Widget _buildTelephoneStep() {
    return Form(
      key: _telephoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mot de passe oublié', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Indiquez votre numéro de téléphone pour recevoir un code de réinitialisation.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          AuthTextField(
            label: 'Numéro de téléphone',
            hint: '70 00 00 00',
            controller: _telephoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le numéro de téléphone est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _requestCode,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Recevoir le code'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep() {
    final pinTheme = MaterialPinTheme(
      shape: MaterialPinShape.outlined,
      borderRadius: BorderRadius.circular(12),
      cellSize: const Size(46, 52),
      borderColor: AppColors.border,
      focusedBorderColor: AppColors.primary,
      filledBorderColor: AppColors.primary,
      fillColor: AppColors.surface,
      focusedFillColor: AppColors.surface,
      filledFillColor: AppColors.surface,
      errorBorderColor: AppColors.error,
    );

    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nouveau mot de passe', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Entrez le code reçu par SMS et choisissez un nouveau mot de passe.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (_devOtpCode != null) ...[
            const SizedBox(height: 16),
            _OtpDebugBanner(otpCode: _devOtpCode!, onCopy: _copyOtp),
          ],
          const SizedBox(height: 24),
          // MaterialPinFormField combine le rendu Material de MaterialPinField
          // avec l'intégration à un Form parent (validator/autovalidate).
          MaterialPinFormField(
            length: AppConstants.otpLength,
            pinController: _pinController,
            keyboardType: TextInputType.number,
            theme: pinTheme,
            validator: (value) {
              if (value == null || value.length != AppConstants.otpLength) {
                return 'Code invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          AuthTextField(
            label: 'Nouveau mot de passe',
            controller: _newPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Minimum 8 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _resetPassword,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Réinitialiser le mot de passe'),
          ),
        ],
      ),
    );
  }
}

class _OtpDebugBanner extends StatelessWidget {
  const _OtpDebugBanner({required this.otpCode, required this.onCopy});
  final String otpCode;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Code de test : ',
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    TextSpan(
                      text: otpCode,
                      style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.copy_outlined, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}