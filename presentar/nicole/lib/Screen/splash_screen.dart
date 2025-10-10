import 'package:flutter/material.dart';
import 'inicio_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _catUpAnimation;
  late Animation<double> _catScaleAnimation;
  late Animation<Alignment> _catAlignment;
  late Animation<double> _textOpacity;

  bool _showText = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // Gato sube desde la parte inferior al centro
    _catUpAnimation = Tween<double>(begin: 200, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack)),
    );

    // Cambiar tamaño
    _catScaleAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.easeInOut)),
    );

    // Mover a la izquierda
    _catAlignment = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(-0.4, 0.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.easeInOut)),
    );

    // Aparecen las letras NICOLE
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();

    // Mostrar texto en el momento adecuado
    Future.delayed(const Duration(milliseconds: 2500), () {
      setState(() => _showText = true);
    });

    // Pasar al inicio después de la animación
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InicioScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/fondo.png',
              fit: BoxFit.cover,
            ),
          ),

          // Gato + texto animado
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Align(
                alignment: _catAlignment.value,
                child: Transform.translate(
                  offset: Offset(0, _catUpAnimation.value),
                  child: Transform.scale(
                    scale: _catScaleAnimation.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icono.png',
                          height: 150,
                        ),
                        const SizedBox(width: 15),
                        if (_showText)
                          FadeTransition(
                            opacity: _textOpacity,
                            child: const Text(
                              "NICOLE",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
