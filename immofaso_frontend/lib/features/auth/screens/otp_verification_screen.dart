import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.telephone,
    this.initialOtpCode,
  });

  final String telephone;
  final String? initialOtpCode;

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _pinController = PinInputController();
  Timer? _timer;
  int _secondsRemaining = AppConstants.otpResendDelaySeconds;
  String? _errorText;
  String? _devOtpCode;

  @override
  void initState() {
    super.initState();
    _devOtpCode = widget.initialOtpCode;
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _secondsRemaining = AppConstants.otpResendDelaySeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _resendCode() async {
    try {
      final otpCode = await ref.read(authRepositoryProvider).resendOtp(telephone: widget.telephone);
      _startResendTimer();
      if (!mounted) return;
      setState(() => _devOtpCode = otpCode);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Un nouveau code a été envoyé.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    }
  }

  void _submit(String code) {
    setState(() => _errorText = null);
    if (code.length != AppConstants.otpLength) return;
    ref.read(authControllerProvider.notifier).verifyOtp(
          telephone: widget.telephone,
          otpCode: code,
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
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        setState(() => _errorText = next.message);
        _pinController.clear();
        _pinController.triggerError();
      }
    });

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Image(image: AssetImage('assets/icons/icon2.png'), width: 48, height: 48),
              const Icon(Icons.sms_outlined, color: AppColors.primary, size: 40),
              const SizedBox(height: 20),
              Text('Vérification du numéro', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Entrez le code à 6 chiffres envoyé au ${widget.telephone}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_devOtpCode != null) ...[
                const SizedBox(height: 16),
                _OtpDebugBanner(otpCode: _devOtpCode!, onCopy: _copyOtp),
              ],
              const SizedBox(height: 32),
              MaterialPinField(
                length: AppConstants.otpLength,
                pinController: _pinController,
                autoFocus: true,
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                errorText: _errorText,
                theme: MaterialPinTheme(
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
                  entryAnimation: MaterialPinAnimation.fade,
                ),
                onCompleted: _submit,
                onChanged: (_) {},
              ),
              const SizedBox(height: 24),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              const Spacer(),
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Renvoyer le code dans ${_secondsRemaining}s',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : TextButton(
                        onPressed: _resendCode,
                        child: const Text('Renvoyer le code'),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
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