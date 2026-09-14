import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: AppConfig.demoEmail);
    _password = TextEditingController(text: AppConfig.demoPassword);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final strings = ref.read(stringsProvider);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).login(
            _email.text.trim(),
            _password.text,
          );
    } catch (error) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() {
        _error = errorMessageFor(
          error,
          strings.t('state.offline'),
          strings.t('login.failed'),
        );
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
                        alignment: AlignmentDirectional.centerStart,
                        child: BrandMark(size: 64, pulse: true),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Appear.stagger(
                      index: 1,
                      child: Text(
                        strings.t('app.name'),
                        style: AppText.display,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Appear.stagger(
                      index: 2,
                      child: Text(
                        strings.t('app.role'),
                        style: AppText.title.copyWith(color: AppColors.primary),
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
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A1A120E),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              strings.t('login.title'),
                              style: AppText.heading,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              strings.t('login.subtitle'),
                              style: AppText.bodyMuted,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppTextField(
                              label: strings.t('login.email'),
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.mail_outline_rounded,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              label: strings.t('login.password'),
                              controller: _password,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icons.lock_outline_rounded,
                              onSubmitted: (_) => _submit(),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.danger,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: AppText.body.copyWith(
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: strings.t('login.submit'),
                              busy: _submitting,
                              icon: Icons.login_rounded,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              strings.t('login.demo_hint'),
                              style: AppText.label,
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
