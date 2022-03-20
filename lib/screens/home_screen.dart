import 'dart:async';

import 'package:fallback/const.dart';
import 'package:fallback/enums.dart';
import 'package:fallback/services/firebase_services.dart';
import 'package:fallback/services/greeting_service.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/widgets_basic/backup_code_card.dart';
import 'package:fallback/widgets_basic/cloud_sync_state_card.dart';
import 'package:fallback/widgets_basic/material_you/you_alert_dialog.dart';
import 'package:flutter/material.dart';

import '../widgets_basic/buttons/custom_material_button.dart';
import '../widgets_basic/custom_app_bar.dart';


class HomeScreen extends StatefulWidget {
  final SecureStorage secureStorage;
  final FirebaseServices firebaseServices;
  const HomeScreen({Key? key,required this.secureStorage,required this.firebaseServices}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState(secureStorage,firebaseServices);
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {


  final SecureStorage secureStorage;
  final FirebaseServices firebaseServices;

  HomeScreenState(this.secureStorage,this.firebaseServices);


  late AnimationController _animationController;
  late Animation<double> _animation;

  // late Future<Map<String,dynamic>> keys;

  void fetchKeys() async{
    // keys=secureStorage.readKeys();
    // await keys;
    setState(() {});
  }


  @override
  void initState() {
    // fetchKeys();
    // homeScreenTrigger.addListener(() {
    //   if(!mounted){
    //     Timer(const Duration(milliseconds: 500),(){
    //       setState(() {});
    //     });
    //   }else{
    //     setState(() {});
    //   }
    // });

    _animationController=AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250)
    );

    _animation=Tween<double>(
      begin: 0,
      end: 1
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    super.initState();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: CustomScrollView(
          slivers: [
            CustomSliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.search_rounded,color: kIconColor,),
                onPressed: () {},
              ),
              titleText: getGreeting(),
              actions: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: IconButton(
                    icon: const Icon(Icons.supervised_user_circle),
                    color: kIconColor,
                    onPressed: (){
                      showDialog(
                        context: context,
                        builder: (context)=>YouAlertDialog(
                          title: const Text("Force Stop?",style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600
                          ),),
                          content: const Text("If you force stop an app, it may misbehave",),
                          backgroundColor: kBackgroundColor,
                          actions: [
                            OutlinedButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel",style: TextStyle(color: kIconColor),),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                side: const BorderSide(color: kIconColor),
                                primary: kIconColor,
                              ),
                            ),
                            CustomMaterialButton(
                              child: const Text("OK",style: TextStyle(color: kBackgroundColor,),),
                              buttonColor: kIconColor,
                              onPressed: (){

                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              backgroundColor: Colors.transparent,
            ),
            // SliverToBoxAdapter(
            //   child: ,
            // ),
            FutureBuilder(
              future: secureStorage.readKeys(),
              builder: (BuildContext context, AsyncSnapshot<Map<String,dynamic>> snapshot) {
                if(snapshot.connectionState==ConnectionState.waiting || (!snapshot.hasData && !snapshot.hasError)){
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(strokeWidth: 2,color: kIconColor,),));
                }
                if(snapshot.hasError || snapshot.data!['businesses'].isEmpty){
                  return const SliverToBoxAdapter(child: Center(child: Text("No data"),));
                }
                return SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    AnimatedSize(
                      duration: const Duration(milliseconds:250),
                      child: FutureBuilder(
                        future: firebaseServices.performCloudSync(),
                        builder: (BuildContext context, AsyncSnapshot<CloudSyncStatus> snapshot){
                          if(snapshot.connectionState==ConnectionState.waiting){
                            return const CloudSyncStateCard(
                              leading: CircularProgressIndicator(color: kIconColor, strokeWidth: 2,),
                              title: Text("Syncing with Cloud",style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20
                              ),),
                            );
                          }
                          if(snapshot.data==CloudSyncStatus.networkError){
                            return const CloudSyncStateCard(
                              leading: Icon(Icons.cloud_off_rounded, color: kIconColor,),
                              title: Text("Check you internet connection",style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),),
                            );
                          }else if(snapshot.data==CloudSyncStatus.encryptionPasswordNotSet){
                            return const CloudSyncStateCard(
                              leading: Icon(Icons.lock_open_rounded, color: kIconColor,),
                              title: Text("Set encryption password",style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),),
                            );
                          }else if(snapshot.data==CloudSyncStatus.notSignedIn){
                            return const CloudSyncStateCard(
                              leading: Icon(Icons.cloud_off_outlined, color: kIconColor,),
                              title: Text("Not Signed In", style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),),
                            );
                          }
                          return Container(
                            height: 25,
                          );
                        },
                      ),
                    ),
                    for(int i=0;i<snapshot.data!['businesses'].length;i++)
                      BackupCodeCard(
                        businessName: snapshot.data!['businesses'][i]['businessName'],
                        nickname: snapshot.data!['businesses'][i]['nickname'],
                        keyList: snapshot.data!['businesses'][i]['codes'],
                        lastModified: snapshot.data!['businesses'][i]['lastModified'],
                        secureStorage: secureStorage,
                        onSuccess: fetchKeys
                      ),
                  ]),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
