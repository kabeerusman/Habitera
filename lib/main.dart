import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitera/common/theme/app_theme_data.dart';
import 'package:habitera/features/auth/presentation/auth_provider.dart';
import 'package:habitera/notification_service.dart';
// import 'package:habitera/isar_service.dart';
import 'package:habitera/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  // await IsarService.init();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce
    )
  );

  await NotificationService.initNotification();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late StreamSubscription _linkSubscription;

  @override
  void initState() {
    super.initState();
    _linkSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      authState,
    ) {
      if (authState.event == AuthChangeEvent.passwordRecovery && mounted) {
        ref.read(isPasswordRecoveryProvider.notifier).setRecovery(true);
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Habitera',
      theme: AppThemeData.lightTheme,
      debugShowCheckedModeBanner: false,
    );



  // when app is launched from cold start, exchange token from URL, android config authoptions part

  // final prefs = await SharedPreferences.getInstance();
  // prefs.clear();
    //* For testing purposes only, to avoid going through the auth flow
    // return MaterialApp(
    //   title: 'Habitera',
    //   theme: AppThemeData.lightTheme,
    //   debugShowCheckedModeBanner: false,
    //   home: ConfirmEmailScreen(email: ''),
    // );
  }
}

    // signingConfigs {
    //     create("release") {
    //         keyAlias = keystoreProperties["keyAlias"] as String
    //         keyPassword = keystoreProperties["keyPassword"] as String
    //         storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
    //         storePassword = keystoreProperties["storePassword"] as String
    //     }
    // }

  