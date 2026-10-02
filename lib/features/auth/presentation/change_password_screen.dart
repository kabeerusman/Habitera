import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/features/auth/presentation/auth_provider.dart';
import 'package:habitera/features/auth/presentation/widgets/auth_circular_progress.dart';
import 'package:habitera/features/auth/presentation/widgets/signin_field.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pushed from Settings' "Change password" row. Unlike
/// ForgotpasswordScreen/ResetPasswordScreen (email round-trip, recovery
/// session), this re-authenticates with the current password in place so
/// the update happens without leaving the app.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  var _obscureCurrent = true;
  var _obscureNew = true;
  var _obscureConfirm = true;
  var _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm Password is required';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _forgotPassword() async {
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      messenger.showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 4),
          content: Text('Password reset link sent. Check your email.'),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Something went wrong. Try again')),
      );
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email == null) return;

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final authService = ref.read(authServiceProvider);
    try {
      // The client SDK trusts the active session for updateUser, so the
      // current password has to be checked explicitly — re-signing in with
      // it is the only way to confirm it's actually correct.
      await authService.signInWithEmailPassword(
        email,
        _currentPasswordController.text,
      );
      await authService.updatePassword(_newPasswordController.text);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Password updated'),
        ),
      );
    } catch (error) {
      var message = 'Something went wrong. Try again';
      if (error is SocketException || error is AuthRetryableFetchException) {
        message = 'Please check your internet connection';
      } else if (error is AuthException) {
        message = error.message.toLowerCase().contains('credentials')
            ? 'Current password is incorrect'
            : error.message;
      }
      messenger.showSnackBar(
        SnackBar(duration: const Duration(seconds: 2), content: Text(message)),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _visibilityToggle(bool obscured, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: ColorPicker.ink400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: Padding(
          padding: padAll16,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your current password, then choose a new one',
                  style: context.body.copyWith(
                    fontSize: 15,
                    color: ColorPicker.ink500,
                  ),
                ),
                kSizedBoxH20,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SigninField(
                          title: 'Current Password',
                          obscureText: _obscureCurrent,
                          controller: _currentPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Current password is required'
                              : null,
                          labelText: 'Enter your current password',
                          suffixIcon: _visibilityToggle(
                            _obscureCurrent,
                            () => setState(
                              () => _obscureCurrent = !_obscureCurrent,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: context.small.copyWith(
                                color: ColorPicker.ink500,
                              ),
                            ),
                          ),
                        ),
                        kSizedBoxH10,
                        SigninField(
                          title: 'New Password',
                          obscureText: _obscureNew,
                          controller: _newPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          validator: _validateNewPassword,
                          labelText: 'Enter a strong password',
                          suffixIcon: _visibilityToggle(
                            _obscureNew,
                            () => setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                        kSizedBoxH5,
                        Text(
                          'At least 6 characters',
                          style: context.small.copyWith(
                            color: ColorPicker.ink500,
                          ),
                        ),
                        kSizedBoxH20,
                        SigninField(
                          title: 'Confirm Password',
                          obscureText: _obscureConfirm,
                          controller: _confirmPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          validator: _validateConfirmPassword,
                          labelText: 'Re-enter your new password',
                          suffixIcon: _visibilityToggle(
                            _obscureConfirm,
                            () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPicker.ink900,
                      foregroundColor: ColorPicker.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const AuthCircularProgress()
                        : const Text('Update Password'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
