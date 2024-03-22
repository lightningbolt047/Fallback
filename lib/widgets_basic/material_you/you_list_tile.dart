import 'package:flutter/material.dart';

class YouListTile extends StatelessWidget {

  final String titleText;
  final String? subtitleText;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool leaveBottomSpace;

  const YouListTile({Key? key, required this.titleText, this.subtitleText, this.leading, this.trailing, this.leaveBottomSpace=true, this.onTap, this.enabled=true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(titleText,style: const TextStyle(
            fontSize: 18,
          ),),
          enableFeedback: true,
          enabled: enabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          subtitle: subtitleText==null?null:Text(subtitleText!),
          leading: leading,
          onTap: onTap,
        ),
        if(leaveBottomSpace)
          const SizedBox(height: 8,),
      ],
    );
  }
}
