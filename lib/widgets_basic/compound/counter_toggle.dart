import 'package:fallback/const.dart';
import 'package:fallback/enums.dart';
import 'package:fallback/widgets_basic/buttons/simple_rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CounterToggle extends StatelessWidget {
  final int value;
  final Function onTogglePress;
  const CounterToggle({Key? key,required this.value, required this.onTogglePress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SimpleRoundedButton(
          child: const Icon(FontAwesomeIcons.minus, color: kBackgroundColor,),
          onPressed: (){
            onTogglePress(CounterAction.subtract);
          },
        ),
        Text(value.toString(),),
        SimpleRoundedButton(
          child: const Icon(FontAwesomeIcons.plus, color: kBackgroundColor,),
          onPressed: (){
            onTogglePress(CounterAction.add);
          },
        ),
      ],
    );
  }
}
