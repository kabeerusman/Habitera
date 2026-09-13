import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/features/auth/presentation/auth_provider.dart';
import 'package:habitera/features/auth/presentation/widgets/auth_circular_progress.dart';
import 'package:habitera/features/auth/presentation/widgets/signin_field.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:habitera/utils/validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: padAll16,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: Text(
                    'Create New Password',
                    style: context.screenTitle,
                  ),
                ),
                kSizedBoxH20,
                SigninField(
                  title: 'Password',
                  obscureText: false,
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  validator: Validators.validatePassword,
                  labelText: 'Enter your new password',
                ),
                kSizedBoxH20,
                SigninField(
                  title: 'Confirm Password',
                  obscureText: false,
                  controller: _confirmPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  labelText: 'Confirm your new password',
                ),
                kSizedBoxH20,
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              final authService = ref.read(authServiceProvider);
                              await authService.updatePassword(
                                _confirmPasswordController.text,
                              );
                              ref
                                  .read(isPasswordRecoveryProvider.notifier)
                                  .setRecovery(false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 4),
                                    content: Text(
                                      'Password reset successfully',
                                    ),
                                  ),
                                );
                                context.goNamed(AppRoutes.navbar.name);
                              }
                            } catch (error) {
                              var message = 'Something went wrong. Try again';
                              if (error is AuthRetryableFetchException) {
                                message =
                                    'Please check your internet connection';
                              } else if (error is AuthException) {
                                message = error.message;
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 2),
                                    content: Text(message),
                                  ),
                                );
                              }
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                            return;
                          }
                        },
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  child: _isLoading ? AuthCircularProgress() : Text('Reset'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
