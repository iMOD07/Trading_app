import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'features/login/ui/login_screen.dart';
import 'features/main_navigation.dart';
import 'features/admin/ui/admin_navigation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await ApiService.init();
  final isLoggedIn = await AuthService.isLoggedIn();
  final isAdmin = isLoggedIn ? await AuthService.isAdmin() : false;
  runApp(TradingApp(isLoggedIn: isLoggedIn, isAdmin: isAdmin));
}

class TradingApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isAdmin;
  const TradingApp(
      {super.key, required this.isLoggedIn, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (!isLoggedIn) {
      home = const LoginScreen();
    } else if (isAdmin) {
      home = const AdminNavigation();
    } else {
      home = const MainNavigation();
    }

    return MaterialApp(
      title: 'IBKR Trading',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: home,
    );
  }
}
