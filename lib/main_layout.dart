import 'package:animations/animations.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:fallback/screens/add_code_screen.dart';
import 'package:fallback/screens/home_screen.dart';
import 'package:fallback/screens/settings_screen.dart';
import 'package:fallback/services/greeting_service.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/widgets_basic/backup_code_card.dart';
import 'package:fallback/widgets_basic/buttons/bottomAppBarButton.dart';
import 'package:fallback/widgets_basic/buttons/custom_material_button.dart';
import 'package:fallback/widgets_basic/material_you/custom_alert_dialog.dart';
import 'package:fallback/widgets_basic/text_widgets/screen_header_text.dart';
import 'package:flutter/material.dart';
import 'enums.dart';
import 'package:google_fonts/google_fonts.dart';

import 'const.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with SingleTickerProviderStateMixin {

  Screen _selectedScreen=Screen.home;

  late Future<SecureStorage> _secureStorage;

  void biometricAvailabilityCheck() async{

    _secureStorage=SecureStorage.getInstance();

    CanAuthenticateResponse availability=await (await _secureStorage).getBiometricStatus();
    if(availability==CanAuthenticateResponse.success){
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context)=>WillPopScope(
        onWillPop: ()async=>false,
        child: CustomAlertDialog(
          title: Builder(
            builder: (context){
              String titleText="Fail";
              if(availability==CanAuthenticateResponse.errorHwUnavailable){
                titleText="Fingerprint/Face unlock hardware busy";
              }else if(availability==CanAuthenticateResponse.errorNoHardware){
                titleText="No biometric hardware found";
              }else if(availability==CanAuthenticateResponse.errorNoBiometricEnrolled){
                titleText="Not enrolled";
              }
              return Text(titleText,style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),);
            },
          ),
          content: Builder(
            builder: (context){
              String subtitleText="Fail";
              if(availability==CanAuthenticateResponse.errorHwUnavailable){
                subtitleText="Fingerprint/Face unlock hardware is being used by another app";
              }else if(availability==CanAuthenticateResponse.errorNoHardware){
                subtitleText="Your device is not supported";
              }else if(availability==CanAuthenticateResponse.errorNoBiometricEnrolled){
                subtitleText="Enroll your fingerprint/face from system settings before proceeding";
              }
              return Text(subtitleText,);
            },
          ),
          actions: const [],
        ),
      ),
    );
  }


  @override
  void initState() {
    biometricAvailabilityCheck();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: kBackgroundColor,
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BottomAppBarButton(
                iconData: Icons.home,
                text: "Home",
                isSelected: _selectedScreen==Screen.home,
                onPressed: (){
                  setState(() {
                    _selectedScreen=Screen.home;
                  });
                },
              ),
              BottomAppBarButton(
                iconData: Icons.settings,
                text: "Settings",
                isSelected: _selectedScreen==Screen.settings,
                onPressed: (){
                  setState(() {
                    _selectedScreen=Screen.settings;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        scale: _selectedScreen==Screen.home?1:0,
        child: FutureBuilder(
          future: _secureStorage,
          builder: (BuildContext context,AsyncSnapshot<SecureStorage> snapshot) {
            if(!snapshot.hasData){
              return const CircularProgressIndicator(strokeWidth: 2,color: kLightIconColor,);
            }
            return OpenContainer(
              middleColor: kFloatingActionButtonColor,
              useRootNavigator: true,
              transitionDuration: const Duration(milliseconds: 500),
              transitionType: ContainerTransitionType.fadeThrough,
              closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
              ),
              closedBuilder: (BuildContext context,VoidCallback openContainer)=>FloatingActionButton(
                onPressed: () {
                  openContainer();
                },
                backgroundColor: kFloatingActionButtonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                ),
                child: const Icon(Icons.add,color: Colors.black,),
              ),
              openBuilder: (BuildContext context,VoidCallback closeContainer)=>AddCodeScreen(secureStorage: snapshot.data!,),
            );
          }
        ),
      ),
      body: FutureBuilder(
        future: _secureStorage,
        builder: (BuildContext context,AsyncSnapshot<SecureStorage> snapshot){
          if(!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2,color: kIconColor,),
            );
          }
          if(_selectedScreen==Screen.settings){
            return SettingsScreen(secureStorage: snapshot.data!,);
          }
          return HomeScreen(secureStorage: snapshot.data!,);
        },
      ),
    );
  }
}