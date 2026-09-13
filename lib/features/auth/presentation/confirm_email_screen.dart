import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/features/auth/presentation/auth_provider.dart';
import 'package:habitera/features/auth/presentation/widgets/auth_circular_progress.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfirmEmailScreen extends ConsumerStatefulWidget {
  const ConfirmEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  var _isLoading = false;
  var _countdown = 60;
  late Timer _timer;

  int startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_countdown == 0) {
        _timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
    return _countdown;
  }

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padAll16,
          child: Column(
            children: [
              SizedBox(height: 60),
              Text('Confirm your email', style: context.screenTitle),
              kSizedBoxH15,
              Text(
                "We've sent a confirmation email to your email address. Please check your inbox and click the link to verify your account",
                style: context.body.copyWith(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),

              kSizedBoxH20,
              ElevatedButton(
                onPressed: () {
                  context.goNamed(AppRoutes.loginScreen.name);
                },

                child: Text('Back to Login'),
              ),

              kSizedBoxH5,
              ElevatedButton(
                onPressed: _isLoading || _countdown > 0
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          final authService = ref.read(authServiceProvider);
                          await authService.resendLink(widget.email);

                          setState(() {
                            _countdown = 60;
                          });
                          startCountdown();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 4),
                                content: Text(
                                  'Confirmation email link sent. Check your email.',
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
                      },
                child: _isLoading
                    ? AuthCircularProgress()
                    : Text(
                        _countdown > 0
                            ? 'Resend in ${_countdown}s'
                            : 'Resend Link',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
