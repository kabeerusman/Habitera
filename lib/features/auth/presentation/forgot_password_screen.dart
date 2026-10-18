import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/features/auth/presentation/auth_provider.dart';
import 'package:habitera/features/auth/presentation/widgets/auth_circular_progress.dart';
import 'package:habitera/features/auth/presentation/widgets/signin_field.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:habitera/utils/validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotpasswordScreen extends ConsumerStatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  ConsumerState<ForgotpasswordScreen> createState() =>
      _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends ConsumerState<ForgotpasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password', style: context.screenTitle),
      ),
      body: Padding(
        padding: padAll16,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Align(
              //   alignment: AlignmentGeometry.centerLeft,
              //   child: Text('Forgot Password', style: context.screenTitle),
              // ),
              kSizedBoxH5,
              Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Text(
                  'Please enter your e-mail address to get a reset link',
                  style: context.body.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                  ),
                  // style: context.bodyBig,
                ),
              ),
              kSizedBoxH20,
              SigninField(
                title: 'Email Address',
                obscureText: false,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                labelText: 'youremail@mail.com',
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            final authService = ref.read(authServiceProvider);
                            await authService.sendPasswordResetEmail(
                              _emailController.text,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 4),
                                  content: Text(
                                    'Password reset link sent. Check your email.',
                                  ),
                                ),
                              );
                            }
                          } catch (error) {
                            var message = 'Something went wrong. Try again';
                            if (error is AuthRetryableFetchException) {
                              message = 'Please check your internet connection';
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? ColorPicker.sky600
                      : ColorPicker.ink900,
                  foregroundColor: isDark
                      ? ColorPicker.darkTextTitle
                      : ColorPicker.white,
                  shape: StadiumBorder(),
                ),

                child: _isLoading ? AuthCircularProgress() : Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
