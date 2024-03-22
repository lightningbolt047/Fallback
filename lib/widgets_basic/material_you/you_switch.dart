import 'package:fallback/const.dart';
import 'package:flutter/material.dart';

class YouSwitch extends StatefulWidget {
  final bool value;
  final Function onChanged;
  const YouSwitch({Key? key,required this.value,required this.onChanged}) : super(key: key);

  @override
  State<YouSwitch> createState() => YouSwitchState(value,onChanged);
}

class YouSwitchState extends State<YouSwitch> {

  bool value;
  final Function onTap;

  YouSwitchState(this.value,this.onTap);

  Future<void> onSwitchPress() async{
    try{
      await onTap(!value);
      if(value){
        setOff();
      }else{
        setOn();
      }
    }catch(e){
      return Future.error(e);
    }
  }

  void setOn(){
    setState(() {
      value=true;
    });
  }

  void setOff(){
    setState(() {
      value=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 28,
          width: 58,
          decoration: BoxDecoration(
            color: value?kIconColor:kDisabledColor,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          right: value?2:28,
          left: value?28:2,
          bottom: 2,
          child: Container(
            height: 24,
            width: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kBackgroundColor,
            ),
          ),
        )
      ],
    );
  }
}
