import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(
    fileName: 'assets/env',
  );

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    const LafortezaAdvMobProg(),
  );
}

class LafortezaAdvMobProg
    extends StatelessWidget {
  const LafortezaAdvMobProg({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize:
            const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (
          context,
          child,
        ) {
          final themeModel =
              context.watch<
                  ThemeProvider>();

          return MaterialApp(
            debugShowCheckedModeBanner:
                false,

            title: 'E-Commerce App',

            theme:
                themeModel.lightTheme,

            darkTheme:
                themeModel.darkTheme,

            themeMode:
                themeModel.isDark
                    ? ThemeMode.dark
                    : ThemeMode.light,

            initialRoute:
                '/splash',

            routes: {
              '/splash': (context) =>
                  const SplashScreen(),

              '/signin': (context) =>
                  const SignInScreen(),

              '/signup': (context) =>
                  const SignupScreen(),

              '/home': (context) =>
                  const HomeScreen(),

              '/cart': (context) =>
                  const CartScreen(),

              '/settings': (context) =>
                  const SettingsScreen(),

              '/profile': (context) =>
                  const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}