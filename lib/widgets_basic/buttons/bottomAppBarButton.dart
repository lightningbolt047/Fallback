import 'package:flutter/material.dart';

import '../../const.dart';

class BottomAppBarButton extends StatelessWidget {

  final IconData iconData;
  // final Widget selectedIcon;
  final String text;
  // final Color selectedTextColor;
  final bool isSelected;
  final VoidCallback onPressed;

  const BottomAppBarButton({Key? key,required this.iconData, required this.text, this.isSelected=false, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100)
      ),
      elevation: 0,
      highlightElevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 2),
            decoration: BoxDecoration(
              color: isSelected?kIconColor:kBackgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(15)
            ),
            child: Icon(iconData,color: isSelected?kBackgroundColor:kIconColor,),
          ),
          Text(text,style: const TextStyle(
            color: kIconColor,
          ),),
        ],
      ),
    );
  }
}
