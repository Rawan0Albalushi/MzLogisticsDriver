import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/appear.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/async_states.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../providers/auth_controller.dart';

class ActivateScreen extends ConsumerStatefulWidget {
  const ActivateScreen({super.key});

  @override
  ConsumerState<ActivateScreen> createState() => _ActivateScreenState();
}

class _ActivateScreenState extends ConsumerState<ActivateScreen> {
  late final TextEditingController _phone;
  late final TextEditingController _code;
  late final TextEditingController _password;
  late final TextEditingController _confirm;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController();
    _code = TextEditingController();
    _password = TextEditingController();
    _confirm = TextEditingController();
  }

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final strings = ref.read(stringsProvider);
    final phone = _phone.text.trim();
    final code = _code.text.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      setState(() => _error = strings.t('activate.phone_required'));
      return;
    }
    if (code.length != 6) {
      setState(() => _error = strings.t('activate.code_required'));
      return;
    }
    if (_password.text.length < 8) {
      setState(() => _error = strings.t('activate.password_length'));
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = strings.t('activate.password_mismatch'));
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).activate(
            phone: phone,
            code: code,
            password: _password.text,
          );
    } catch (error) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      final message = errorMessageFor(
        error,
        strings.t('state.offline'),
        strings.t('activate.failed'),
      );
      setState(() {
        _error = message.toLowerCase().contains('too many')
            ? strings.t('activate.locked')
            : message == strings.t('state.offline')
                ? message
                : strings.t('activate.failed');
      });
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Appear(
                      child: Align(
                        alignment: Alignment.center,
                        child: BrandMark(size: 64),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Appear.stagger(
                      index: 1,
                      child: Text(
                        strings.t('activate.title'),
                        textAlign: TextAlign.center,
                        style: AppText.display,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Appear.stagger(
                      index: 2,
                      child: Text(
                        strings.t('activate.subtitle'),
                        textAlign: TextAlign.center,
                        style: AppText.bodyMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Appear.stagger(
                      index: 3,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              label: strings.t('activate.phone'),
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.phone_outlined,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              label: strings.t('activate.code'),
                              controller: _code,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.pin_outlined,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              label: strings.t('activate.password'),
                              controller: _password,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.lock_outline_rounded,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              label: strings.t('activate.confirm'),
                              controller: _confirm,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icons.lock_outline_rounded,
                              onSubmitted: (_) => _submit(),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: AppText.body.copyWith(color: AppColors.danger),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: strings.t('activate.submit'),
                              busy: _submitting,
                              icon: Icons.verified_user_outlined,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: Text(strings.t('activate.back_to_login')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
