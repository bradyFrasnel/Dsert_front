import 'package:flutter/material.dart';
import 'package:dsertmobile/view/loginPage.dart';

/// Animation de logo D'Sert avec ScaleTransition
class AnimatedLogo extends StatefulWidget {
  final double size;
  final Duration duration;
  final Curve curve;
  
  const AnimatedLogo({
    super.key,
    this.size = 150.0,
    this.duration = const Duration(seconds: 6),
    this.curve = Curves.fastOutSlowIn,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..repeat(reverse: true);
  
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  @override
  void initState() {
    super.initState();
    
    // Redirection automatique vers la page de connexion après 6 secondes
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/images/logo_Dsert.png',
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}