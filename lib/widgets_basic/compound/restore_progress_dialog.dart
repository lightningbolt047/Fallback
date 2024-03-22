import 'package:flutter/material.dart';
import '../../const.dart';
import '../material_you/you_alert_dialog.dart';

class RestoreProgressDialog extends StatelessWidget {
  const RestoreProgressDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return YouAlertDialog(
      title: const Text("Restoring Backup",style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),),
      backgroundColor: kBackgroundColor,
      content: Row(
        children: const [
          CircularProgressIndicator(strokeWidth: 2, color: kIconColor,),
          SizedBox(width: 12,),
          Text("Backup restore in progress")
        ],
      ),
    );
  }
}