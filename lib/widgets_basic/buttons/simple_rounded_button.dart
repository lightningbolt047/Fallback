import 'package:fallback/const.dart';
import 'package:flutter/material.dart';

class SimpleRoundedButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final Color color;
  const SimpleRoundedButton({Key? key,this.child,this.color=kIconColor,this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: const CircleBorder(),
      color: color,
      enableFeedback: true,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: child,
      ),
      onPressed: onPressed,
    );
  }
}
