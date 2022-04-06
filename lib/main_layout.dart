import 'package:animations/animations.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:fallback/screens/add_code_screen.dart';
import 'package:fallback/screens/home_screen.dart';
import 'package:fallback/screens/settings_screen.dart';
import 'package:fallback/services/firebase_services.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/services/shared_prefs.dart';
import 'package:fallback/widgets_basic/buttons/custom_material_button.dart';
import 'package:fallback/widgets_basic/material_you/you_bottom_app_bar_button.dart';
import 'package:fallback/widgets_basic/material_you/you_alert_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:screen_protector/lifecycle/lifecycle_state.dart';
import 'package:screen_protector/screen_protector.dart';
import 'enums.dart';
import 'dart:io';
import 'const.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends LifecycleState<MainLayout> with SingleTickerProviderStateMixin {

  Screen _selectedScreen=Screen.home;

  final GlobalKey<HomeScreenState> _homeScreenKey=GlobalKey<HomeScreenState>();

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
        child: YouAlertDialog(
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
          backgroundColor: kBackgroundColor,
        ),
      ),
    );
  }

  void informExistingUsers() async{

    final bool? oldUser=await getSetupCompletedPreference();

    if(!oldUser!){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context)=>YouAlertDialog(
          title: const Text("Important Info",style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),),
          content: const Text("If you are an existing user and want to restore backup from the cloud, please DO NOT add or delete keys. Sign In to your account, set your old password as your encryption password, visit the app's home screen and wait for a prompt to restore."),
          actions: [
            CustomMaterialButton(
              child: const Text("OK",style: TextStyle(
              color: kBackgroundColor,
              ),),
              buttonColor: kIconColor,
              onPressed: (){
                setSetupCompletedPreference(true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  Future<FirebaseApp> initializeFirebaseApp() async{
    try{
      return Firebase.initializeApp();
    }catch(e){
      return Future.error(e);
    }
  }


  @override
  void initState() {
    if(Platform.isIOS){
      ScreenProtector.protectDataLeakageWithBlur();
    }else if(Platform.isAndroid){
      ScreenProtector.protectDataLeakageOn();
    }
    informExistingUsers();
    biometricAvailabilityCheck();
    super.initState();
  }

  @override
  void onPaused() {
    if(Platform.isAndroid){
      ScreenProtector.protectDataLeakageOff();
    }
    super.onPaused();
  }

  @override
  void onResumed() {
    if(Platform.isAndroid){
      ScreenProtector.protectDataLeakageOn();
    }
    super.onResumed();
  }


  @override
  void dispose() {
    if(Platform.isIOS){
      ScreenProtector.preventScreenshotOff();
    }
    super.dispose();
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
              YouBottomAppBarButton(
                iconData: Icons.home,
                text: "Home",
                isSelected: _selectedScreen==Screen.home,
                onPressed: (){
                  if(_selectedScreen!=Screen.home){
                    setState(() {
                      _selectedScreen=Screen.home;
                    });
                  }
                },
              ),
              YouBottomAppBarButton(
                iconData: Icons.settings,
                text: "Settings",
                isSelected: _selectedScreen==Screen.settings,
                onPressed: (){
                  if(_selectedScreen!=Screen.settings){
                    setState(() {
                      _selectedScreen=Screen.settings;
                    });
                  }
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
              transitionDuration: const Duration(milliseconds: 300),
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
              openBuilder: (BuildContext context,VoidCallback closeContainer)=>AddCodeScreen(secureStorage: snapshot.data!, onSuccess: _homeScreenKey.currentState!.fetchKeys,keysInputType: KeysInputType.add,),
            );
          }
        ),
      ),
      body: FutureBuilder(
        future: initializeFirebaseApp(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2,color: kIconColor,),
            );
          }
          return FutureBuilder(
            future: _secureStorage,
            builder: (BuildContext context,AsyncSnapshot<SecureStorage> snapshot){
              if(!snapshot.hasData){
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2,color: kIconColor,),
                );
              }

              final FirebaseServices firebaseServices=FirebaseServices(snapshot.data!);

              if(_selectedScreen==Screen.settings){
                return SettingsScreen(secureStorage: snapshot.data!, firebaseServices: firebaseServices, changeScreen: (){
                  setState(() {
                    _selectedScreen=Screen.home;
                  });
                },);
              }
              return HomeScreen(key:_homeScreenKey, secureStorage: snapshot.data!, firebaseServices: firebaseServices);
            },
          );
        }
      ),
    );
  }
}
