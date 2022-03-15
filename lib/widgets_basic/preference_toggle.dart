import 'package:flutter/material.dart';


class PreferenceToggle extends StatefulWidget {

  final String titleText;
  final String subtitleText;
  final Function getPreference;
  final Function onChanged;
  final bool leaveBottomSpace;

  const PreferenceToggle({Key? key, required this.titleText,this.leaveBottomSpace=true, required this.subtitleText, required this.getPreference, required this.onChanged}) : super(key: key);

  @override
  _PreferenceToggleState createState() => _PreferenceToggleState(titleText,subtitleText,leaveBottomSpace,getPreference,onChanged);
}

class _PreferenceToggleState extends State<PreferenceToggle> {

  final String titleText;
  final String subtitleText;
  final Function getPreference;
  final Function onChanged;
  final bool leaveBottomSpace;

  _PreferenceToggleState(this.titleText,this.subtitleText,this.leaveBottomSpace,this.getPreference,this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: getPreference(),
          builder: (BuildContext context,AsyncSnapshot<bool?> snapshot){
            if(!snapshot.hasData){
              return const LinearProgressIndicator();
            }
            return SwitchListTile(
              title: Text(titleText,style: const TextStyle(
                fontSize: 18,
              ),),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)
              ),
              subtitle: Text(subtitleText),
              value: snapshot.data!,
              onChanged: (value) async {
                await onChanged(value);
                setState(() {});
              },
            );
          },
        ),
        if(leaveBottomSpace)
          const SizedBox(height: 8,),
      ],
    );
  }
}
