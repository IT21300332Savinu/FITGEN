import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'views/home_screen.dart';
import 'views/health_dashboard.dart';
import 'views/workout_planner.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const HealthDashboard(),
    ),
    GoRoute(
      path: '/workout',
      builder: (context, state) => const WorkoutPlanner(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AI Medical Guidance',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router, // Use GoRouter
    );
  }
}
