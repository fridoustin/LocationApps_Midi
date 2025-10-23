import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midi_location/auth_gate.dart';
import 'package:midi_location/core/routes/route.dart';
import 'package:midi_location/core/services/notification_service.dart';
import 'package:midi_location/features/auth/presentation/pages/login_screen.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/notification/presentation/provider/notification_provider.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_provider.dart';
import 'package:midi_location/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final container = ProviderContainer();
  await container.read(notificationServiceProvider).initialize(container);

  runApp(ProviderScope(parent: container, child: const MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  bool _isHandlingAuthChange = false;

  void _setupAuthListener() {
    _authSubscription = supabase.auth.onAuthStateChange.listen(
      (data) async {
        final AuthChangeEvent event = data.event;
        if (_isHandlingAuthChange) return;
        _isHandlingAuthChange = true;
        try {
          if (event == AuthChangeEvent.signedIn) {
            final container = ProviderScope.containerOf(
              navigatorKey.currentContext!,
              listen: false,
            );
            container.invalidate(userProfileProvider);
            container.invalidate(dashboardStatsProvider);
            container.invalidate(ulokListProvider);
            container.invalidate(notificationListProvider);
            container.invalidate(ulokTabProvider);
            container.invalidate(kpltNeedInputProvider);
            container.invalidate(kpltInProgressProvider);
            container.invalidate(kpltHistoryProvider);

            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
            return;
          }
          if (event == AuthChangeEvent.signedOut) {
            try {
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                LoginPage.route,
                (route) => false,
              );
            } catch (_) {}
            return;
          }
        } finally {
          Future.microtask(() => _isHandlingAuthChange = false);
        }
      },
      onError: (err) async {
        if (_isHandlingAuthChange) return;
        _isHandlingAuthChange = true;
        try {
          final session = supabase.auth.currentSession;
          if (session != null) {
            try {
              await supabase.auth.signOut();
            } catch (_) {}
          }
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            LoginPage.route,
            (route) => false,
          );
        } finally {
          Future.microtask(() => _isHandlingAuthChange = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Midi Location App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: routeGenerators,
    );
  }
}
