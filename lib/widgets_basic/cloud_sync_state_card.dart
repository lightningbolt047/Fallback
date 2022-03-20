import 'package:flutter/material.dart';

import '../const.dart';

class CloudSyncStateCard extends StatelessWidget {

  final Widget leading;
  final Widget title;

  const CloudSyncStateCard({Key? key,required this.leading, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kAttentionItemColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            leading,
            title
          ],
        ),
      ),
    );
  }
}
