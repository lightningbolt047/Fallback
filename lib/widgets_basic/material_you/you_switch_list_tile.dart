import 'package:fallback/widgets_basic/material_you/you_switch.dart';
import 'package:flutter/material.dart';

class YouSwitchListTile extends StatefulWidget {

  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Function onChanged;
  final bool value;

  const YouSwitchListTile({Key? key,this.title,this.subtitle,this.leading,required this.onChanged,required this.value}) : super(key: key);

  @override
  State<YouSwitchListTile> createState() => YouSwitchListTileState(title,subtitle,leading,onChanged,value);
}

class YouSwitchListTileState extends State<YouSwitchListTile> {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Function onChanged;
  bool value;
  YouSwitchListTileState(this.title,this.subtitle,this.leading, this.onChanged, this.value);

  final GlobalKey<YouSwitchState> switchKey=GlobalKey<YouSwitchState>();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25)
      ),
      subtitle: subtitle,
      leading: leading,
      onTap: () async{
        await onChanged(!value);
        if(value){
          switchKey.currentState!.setOff();
        }else{
          switchKey.currentState!.setOn();
        }
        value=!value;
      },
      trailing: YouSwitch(
        value: value,
        key: switchKey,
        onChanged: onChanged,
      ),
    );
  }
}

