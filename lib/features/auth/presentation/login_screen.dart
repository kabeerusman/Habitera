import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/constants/texts.dart';
import 'package:habitera/features/auth/presentation/widgets/auth_bottom_section.dart';
import 'package:habitera/features/auth/presentation/auth_provider.dart';
import 'package:habitera/features/auth/presentation/widgets/auth_circular_progress.dart';
import 'package:habitera/features/auth/presentation/widgets/signin_field.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:habitera/utils/validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isLoading = false;
  var _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('is now on Login Screen');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 12),
                  Text(
                    appName,
                    style: context.screenTitle.copyWith(fontSize: 26),
                  ),
                  kSizedBoxH85,
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      'Login to your account',
                      style: context.screenTitle,
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  SigninField(
                    title: 'Email Address',
                    obscureText: false,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    labelText: 'Enter your email',
                  ),
                  kSizedBoxH20,
                  SigninField(
                    title: 'Password',
                    obscureText: _obscureText,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    validator: Validators.validatePassword,
                    labelText: 'Enter your password',

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: _obscureText
                          ? Icon(Icons.visibility_rounded)
                          : Icon(Icons.visibility_off_rounded),
                    ),
                  ),
                  kSizedBoxH10,
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.goNamed(AppRoutes.forgotPasswordScreen.name);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: context.body.copyWith(fontSize: 15),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  final authService = ref.read(
                                    authServiceProvider,
                                  );
                                  await authService.signInWithEmailPassword(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                                } catch (error) {
                                  var message =
                                      'Something went wrong. Try again';
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
                                  // print(ref.read(isLoggedInProvider));
                                }
                                // context.goNamed(AppRoutes.navbar.name);
                              }
                              return;
                            },
                      style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                      child: _isLoading
                          ? AuthCircularProgress()
                          : Text('Login'),
                    ),
                  ),
                  kSizedBoxH10,
                  AuthBottomSection(
                    leftText: "Don't have an account?",
                    rightText: 'Create one',
                    onPressed: () =>
                        context.goNamed(AppRoutes.signupScreen.name),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
