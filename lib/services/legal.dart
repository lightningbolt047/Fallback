import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

void showAppAboutDialog(BuildContext context) async{
  showAboutDialog(
      context: context,
      applicationName: "Fallback",
      applicationVersion: (await PackageInfo.fromPlatform()).version,
      applicationIcon: Image.asset("assets/fallback_squircle_logo.png",scale: 7,),
      applicationLegalese: "The developer shall not be responsible in case of loss or damage to life and property resulting from use of this application.\nWhen it comes to the security of your data, I (the developer) do strive for the best and try to make sure your data is stored as safe as possible. Unfortunately, I'm human too and bound to make mistakes. I can try to fix them, but I cannot guarantee fixes and neither am I bound to give them.\nThe application/business icons that are used in this app are properties/trademarks of respective businesses. I do not promote/endorse the usage of these products in any way and I'm not affiliated with any of those businesses."
  );
}