import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_routes.dart';
import 'services/transit_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CommutrApp());
}

/// Commutr: Crowd-Sourced Real-time Public Transit Intelligence App
class CommutrApp extends StatelessWidget {
  const CommutrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransitProvider()),
      ],
      child: MaterialApp(
        title: 'Commutr',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.onboarding,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
