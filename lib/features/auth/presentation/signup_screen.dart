import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/constants/texts.dart';
import 'package:habitera/features/auth/presentation/auth_provider.dart';
import 'package:habitera/features/auth/presentation/widgets/auth_bottom_section.dart';
import 'package:habitera/features/auth/presentation/widgets/auth_circular_progress.dart';
import 'package:habitera/features/auth/presentation/widgets/signin_field.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:habitera/utils/validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isLoading = false;
  var _obscureText = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Container(
                        height: 35,
                        width: 35,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.red,
                        ),
                        child: Image.asset('assets/habitera_icon.png'),
                      ),

                      Text(
                        appName,
                        style: context.screenTitle.copyWith(fontSize: 26),
                      ),
                    ],
                  ),

                  SizedBox(height: 49.0),
                  Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Text(
                      'Create your account',
                      style: context.screenTitle,
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  SigninField(
                    title: 'Name',
                    obscureText: false,
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    validator: Validators.validateName,
                    labelText: 'Enter your name',
                  ),
                  kSizedBoxH15,
                  SigninField(
                    title: 'Email Address',
                    obscureText: false,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    labelText: 'Enter your email',
                  ),
                  kSizedBoxH15,
                  SigninField(
                    title: 'Password',
                    obscureText: _obscureText,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    validator: Validators.validatePassword,
                    labelText: 'Enter a strong password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: _obscureText
                          ? Icon(Icons.visibility_off_rounded)
                          : Icon(Icons.visibility_rounded),
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
                                  await authService.signUpWithEmailPassword(
                                    _emailController.text,
                                    _passwordController.text,
                                    _nameController.text,
                                  );
                                  if (context.mounted) {
                                    context.goNamed(
                                      AppRoutes.confirmEmailScreen.name,
                                      extra: _emailController.text,
                                    );
                                  }
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
                                }
                              }
                              return;
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
                      child: _isLoading
                          ? AuthCircularProgress()
                          : Text('Sign up'),
                    ),
                  ),
                  kSizedBoxH10,
                  AuthBottomSection(
                    leftText: 'Already have an account?',
                    rightText: 'Login here',
                    onPressed: () =>
                        context.goNamed(AppRoutes.loginScreen.name),
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
