import 'package:flutter/material.dart';
import '../../const.dart';


class CustomMaterialButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final Color buttonColor;
  const CustomMaterialButton({Key? key,required this.child,this.buttonColor=kBackgroundColor,this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: child,
      disabledColor: buttonColor.withOpacity(0.5),
      color: buttonColor,
      elevation: 0,
      enableFeedback: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
