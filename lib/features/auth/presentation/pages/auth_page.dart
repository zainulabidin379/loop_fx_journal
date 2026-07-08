import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthenticateRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.go('/dashboard');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(AppDimens.spacingXl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fingerprint, size: 80, color: AppColors.accent),
                  const SizedBox(height: AppDimens.spacingXl),
                  Text(AppStrings.authTitle, style: AppTextStyles.displayLarge),
                  const SizedBox(height: AppDimens.spacingSm),
                  Text(
                    AppStrings.authSubtitle,
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.spacingXxl),
                  if (state is AuthFailure)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.spacingLg),
                      child: Text(
                        AppStrings.authFailed,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (state is AuthUnavailable)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.spacingLg),
                      child: Text(
                        AppStrings.authUnavailable,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  AppButton(
                    label: AppStrings.authButton,
                    icon: Icons.lock_open,
                    isLoading: state is AuthLoading,
                    onPressed: state is AuthLoading
                        ? null
                        : () => context.read<AuthBloc>().add(const AuthenticateRequested()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
