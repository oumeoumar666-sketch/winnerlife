import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/winnerlife_provider.dart';
import 'services/api_service.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'services/facebook_meta_service.dart';
import 'services/payment_gateway_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiService apiService = WinnerLifeRepository();

  try {
    // Initialize Supabase backend
    await Supabase.initialize(
      url: 'https://winnerlife-backend.supabase.co',
      publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.winnerlife_anon_key_placeholder',
    );
    apiService = SupabaseApiService();
  } catch (e) {
    debugPrint('Supabase initialized with offline/fallback repository: $e');
  }

  runApp(WinnerLifeApp(apiService: apiService));
}

class WinnerLifeApp extends StatelessWidget {
  final ApiService? apiService;

  const WinnerLifeApp({super.key, this.apiService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WinnerLifeProvider(repository: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (_) => FacebookMetaService(),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentGatewayService(),
        ),
      ],
      child: MaterialApp(
        title: 'WinnerLife',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A148C), // Royal Deep Purple
            secondary: const Color(0xFFFFB300), // Gold/Amber Accent
            tertiary: const Color(0xFF00897B),  // Teal
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
