import 'package:flutter/material.dart';
import '../const.dart';

class CloudSyncStateCard extends StatelessWidget {

  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback? onTap;

  const CloudSyncStateCard({Key? key,required this.leading, required this.title, this.subtitle, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kAttentionItemColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(top: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if(subtitle!=null)
                    subtitle!
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
