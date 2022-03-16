import 'package:fallback/const.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final Color? backgroundColor;
  const CustomAlertDialog({Key? key,required this.title,required this.content, this.actions=const [],this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      backgroundColor: backgroundColor,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(
              height: 8,
            ),
            content,
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for(int i=0;i<actions.length;i++)...[
                  actions[i],
                  if(i!=actions.length-1)
                    const SizedBox(
                      width: 8,
                    ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
