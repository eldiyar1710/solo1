import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  double progress = 0.0;

  late AnimationController _logoController;
  late AnimationController _circle1Controller;
  late AnimationController _circle2Controller;
  late AnimationController _glowController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _circle1Scale;
  late Animation<double> _circle1Opacity;
  late Animation<double> _circle2Scale;
  late Animation<double> _circle2Opacity;

  @override
  void initState() {
    super.initState();

    // Логотип — пружинная анимация
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _logoScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: -180, end: 0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Пульсирующие фоновые круги
    _circle1Controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _circle2Controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    _circle1Scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(_circle1Controller);

    _circle1Opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.3), weight: 50),
    ]).animate(_circle1Controller);

    _circle2Scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(_circle2Controller);

    _circle2Opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.15, end: 0.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.15), weight: 50),
    ]).animate(_circle2Controller);

    // Пульсирующее свечение логотипа
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    // Запускаем анимацию логотипа
    _logoController.forward();

    // Имитация загрузки + переход
    Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        progress += 1.8;
        if (progress >= 100) {
          progress = 100;
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              context.go(AppRoutes.preHome); // или AppRoutes.home — как у тебя настроено
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _circle1Controller.dispose();
    _circle2Controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF5A61E0),
              Color(0xFF00D4FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Круг 1
            AnimatedBuilder(
              animation: _circle1Controller,
              builder: (_, __) => Positioned(
                top: 100,
                left: 30,
                child: Transform.scale(
                  scale: _circle1Scale.value,
                  child: Opacity(
                    opacity: _circle1Opacity.value,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Круг 2
            AnimatedBuilder(
              animation: _circle2Controller,
              builder: (_, __) => Positioned(
                bottom: 80,
                right: 20,
                child: Transform.scale(
                  scale: _circle2Scale.value,
                  child: Opacity(
                    opacity: _circle2Opacity.value,
                    child: Container(
                      width: 340,
                      height: 340,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00BCD4).withValues(alpha: 0.25),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Основной контент
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Логотип + свечение
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoController, _glowController]),
                    builder: (_, __) {
                      final glow = _glowController.value;
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value * 3.14159 / 180,
                          child: Container(
                            width: 130,
                            height: 130,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                color: const Color(0xFFFFFFFF).withValues(alpha: 0.3 + glow * 0.3),
                                  blurRadius: 50,
                                  spreadRadius: glow * 30,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png', // твой логотип
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Текст
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _logoController,
                      curve: const Interval(0.4, 1.0),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Agent Pro',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Система управления продажами',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Прогресс-бар
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFFFFFFF).withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Загрузка...',
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF).withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Версия
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}