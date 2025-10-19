import 'package:broomie/features/auth/repository/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:broomie/styles/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Broomie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Fade: in 0-800ms, hold 800-2200ms, out 2200-3000ms
    _fadeAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 26,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 46),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 28,
      ),
    ]).animate(_ctrl);

    // Scale: from 0.85 -> 1.05 -> 1.0 over the animation
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_ctrl);

    _ctrl.forward();

    // After animation completes, navigate to AuthWrapper
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // try to load the app icon asset, fallback to text
                if (true)
                  Image.asset(
                    'assets/icon/app_icon.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                const SizedBox(height: 12),
                Text(
                  'broomie',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
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
