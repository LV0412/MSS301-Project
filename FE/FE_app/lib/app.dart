import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/network/api_exception.dart';
import 'features/auth/application/auth_dependencies.dart';
import 'features/auth/data/models/account.dart';
import 'features/auth/presentation/google_web_button.dart';
import 'features/recipe/data/models/recipe.dart';
import 'features/user/application/food_log_store.dart';
import 'features/user/data/models/nutrition_goal.dart';
import 'features/user/data/models/user_profile.dart';

part 'features/auth/presentation/auth_screens.dart';
part 'features/auth/presentation/auth_widgets.dart';
part 'features/auth/presentation/legacy_auth_screens.dart';
part 'features/home/presentation/home_shell.dart';
part 'features/home/presentation/home_widgets.dart';
part 'features/home/presentation/ingredient_scanner_screen.dart';
part 'features/onboarding/presentation/onboarding_screens.dart';
part 'features/onboarding/presentation/onboarding_widgets.dart';
part 'features/recipe/presentation/explore_recipes_screen.dart';
part 'features/recipe/presentation/explore_recipes_widgets.dart';
part 'features/recipe/presentation/meal_planner_widgets.dart';
part 'features/recipe/presentation/personalized_suggestions_screen.dart';
part 'features/recipe/presentation/recipe_details_screen.dart';
part 'features/recipe/presentation/recipe_details_widgets.dart';
part 'features/splash/presentation/splash_screen.dart';
part 'features/user/presentation/edit_basic_profile_screen.dart';
part 'features/user/presentation/favorite_recipes_screen.dart';
part 'features/user/presentation/food_log_screens.dart';
part 'features/user/presentation/profile_screen.dart';
part 'features/user/presentation/profile_widgets.dart';
part 'features/user/presentation/weekly_analysis_screen.dart';
part 'features/user/presentation/weekly_analysis_widgets.dart';

class NutriChefApp extends StatelessWidget {
  const NutriChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriChef AI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          primary: AppColors.green,
          surface: AppColors.card,
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class AppColors {
  static const green = Color(0xFF516C58);
  static const darkGreen = Color(0xFF263D31);
  static const mint = Color(0xFFE3F1D9);
  static const cream = Color(0xFFF4F8EA);
  static const card = Color(0xFFFFFFFF);
  static const field = Color(0xFFEFF4E7);
  static const sand = Color(0xFFECE8D7);
  static const ink = Color(0xFF111D16);
  static const muted = Color(0xFF6D756F);
  static const line = Color(0xFFDDE4D2);
}
