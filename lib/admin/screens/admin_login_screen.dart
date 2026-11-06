import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../admin_theme.dart';
import '../services/admin_auth_service.dart';

/// Two-step login: mobile number → OTP.
/// Allowed numbers and the dummy OTP live in lib/admin/admin_config.dart.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _authService = AdminAuthService();
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      if (!_otpSent) {
        await _authService.sendOtp(_phoneController.text);
        if (mounted) setState(() => _otpSent = true);
      } else {
        // On success the auth gate swaps this screen for the dashboard.
        await _authService.verifyOtp(
          _phoneController.text,
          _otpController.text,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _changeNumber() {
    setState(() {
      _otpSent = false;
      _error = null;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: isWide ? AdminColors.background : AdminColors.sidebar,
      body: Row(
        children: [
          if (isWide) const Expanded(child: _BrandPanel()),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildForm(isWide),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isWide) {
    final phone = _authService.normalizePhone(_phoneController.text);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isWide) ...[
              const Center(child: _Logo()),
              const SizedBox(height: 24),
            ],
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AdminColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _otpSent ? Icons.sms_outlined : Icons.phone_android_rounded,
                color: AdminColors.primaryDark,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _otpSent ? 'Verify OTP' : 'Admin login',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AdminColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _otpSent
                  ? 'Enter the 4-digit code sent to $phone'
                  : 'Enter your registered mobile number to continue.',
              style: const TextStyle(color: AdminColors.muted, height: 1.4),
            ),
            const SizedBox(height: 28),
            if (!_otpSent)
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                autofocus: true,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  hintText: '+91 96568 61728',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
                validator: (val) {
                  final digits = (val ?? '').replaceAll(RegExp(r'\D'), '');
                  return digits.length < 10
                      ? 'Enter a valid mobile number'
                      : null;
                },
              )
            else ...[
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                autofocus: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (_) => _submit(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 18,
                ),
                decoration: const InputDecoration(
                  hintText: '••••',
                  counterText: '',
                ),
                validator: (val) =>
                    RegExp(r'^\d{4}$').hasMatch(val?.trim() ?? '')
                        ? null
                        : 'Enter the 4-digit OTP',
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isSubmitting ? null : _changeNumber,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Change number'),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AdminColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AdminColors.danger,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AdminColors.danger,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(_otpSent ? 'Verify & log in' : 'Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AdminColors.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'BITEBOX',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Admin',
          style: TextStyle(
            color: AdminColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

/// Left half of the desktop login screen.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    Widget point(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AdminColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(text, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AdminColors.sidebar, Color(0xFF14513A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Logo(),
          const Spacer(),
          const Text(
            'Manage your\nBiteBox website.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Changes you make here appear on the public site instantly.',
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
          const SizedBox(height: 40),
          point(Icons.contact_phone_outlined, 'Contact details & social links'),
          point(Icons.insights_rounded, 'Home page numbers'),
          point(Icons.storefront_outlined, 'Machine locations'),
          point(Icons.inbox_outlined, 'Franchise enquiries'),
          const Spacer(),
          const Text(
            '© 2026 BiteBox 24/7',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
