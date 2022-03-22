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
        child: FutureBuilder(
            future: secureStorage.readKeys(),
            builder: (BuildContext context, AsyncSnapshot<Map<String,dynamic>> snapshot) {
              if(snapshot.connectionState==ConnectionState.waiting || (!snapshot.hasData && !snapshot.hasError)){
                return const Center(child: CircularProgressIndicator(strokeWidth: 2,color: kIconColor,),);
              }
              // if(snapshot.hasError || snapshot.data!['businesses'].isEmpty){
              //   return const SliverToBoxAdapter(child: Center(child: Text("No data"),));
              // }
              return CustomScrollView(
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
                  SliverToBoxAdapter(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds:250),
                      child: FutureBuilder(
                        future: firebaseServices.performCloudSync(context),
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
                          }else if(snapshot.data==CloudSyncStatus.notSignedIn){
                            return CloudSyncStateCard(
                              leading: const Icon(Icons.cloud_off_outlined, color: kIconColor,),
                              title: const Text("Not Signed In", style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),),
                              subtitle: const Text("Important! Read More",style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),),
                              onTap: (){
                                showDialog(
                                  context: context,
                                  builder: (context)=>YouAlertDialog(
                                    title: const Text("Attention",style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),),
                                    backgroundColor: kBackgroundColor,
                                    content: const Text("Old users: If you have used this app before and want to restore a cloud backup, please do not make any modifications by adding or removing keys. Please sign in to your account, set you encryption password as your old password and come back to this screen to restore your keys.\n\nNew users: You are free to login to cloud to safely backup your keys. Cloud backups are completely encrypted by your encryption password"),
                                    actions: [
                                      CustomMaterialButton(
                                        child: const Text("OK",style: TextStyle(
                                          color: kBackgroundColor,
                                        ),),
                                        buttonColor: kIconColor,
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }else if(snapshot.data==CloudSyncStatus.encryptionPasswordNotSet){
                            return const CloudSyncStateCard(
                              leading: Icon(Icons.lock_open_rounded, color: kIconColor,),
                              title: Text("Set encryption password",style: TextStyle(
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
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((BuildContext context, int index){
                        List<List<String>> codesString=[];
                        for(int i=0;i<snapshot.data!['businesses'][index]['codes'].length;i++){
                          codesString.add([]);
                          for(int j=0;j<snapshot.data!['businesses'][index]['codes'][i].length;j++){
                            codesString[i].add(snapshot.data!['businesses'][index]['codes'][i][j]);
                          }
                        }

                        return BackupCodeCard(
                            businessName: snapshot.data!['businesses'][index]['businessName'],
                            nickname: snapshot.data!['businesses'][index]['nickname'],
                            keyList: codesString,
                            lastModified: snapshot.data!['businesses'][index]['lastModified'],
                            secureStorage: secureStorage,
                            onSuccess: fetchKeys
                        );
                      },
                      childCount: snapshot.data!['businesses'].length

                    ),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }
}
