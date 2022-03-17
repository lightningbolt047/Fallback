import 'package:fallback/const.dart';
import 'package:fallback/services/firebase_services.dart';
import 'package:fallback/services/greeting_service.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/services/stirng_services.dart';
import 'package:fallback/utils/home_screen_trigger.dart';
import 'package:fallback/widgets_basic/backup_code_card.dart';
import 'package:fallback/widgets_basic/buttons/bottomAppBarButton.dart';
import 'package:fallback/widgets_basic/material_you/custom_alert_dialog.dart';
import 'package:fallback/widgets_basic/text_widgets/screen_header_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

import '../widgets_basic/buttons/custom_material_button.dart';
import '../widgets_basic/custom_app_bar.dart';
import 'add_code_screen.dart';
import 'package:biometric_storage/biometric_storage.dart';


class HomeScreen extends StatefulWidget {
  final SecureStorage secureStorage;
  final FirebaseServices firebaseServices;
  const HomeScreen({Key? key,required this.secureStorage,required this.firebaseServices}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState(secureStorage,firebaseServices);
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {


  final SecureStorage secureStorage;
  final FirebaseServices firebaseServices;

  _HomeScreenState(this.secureStorage,this.firebaseServices);


  late AnimationController _animationController;
  late Animation<double> _animation;

  late Future<Map<String,dynamic>> keys;

  void fetchKeys() async{
    keys=secureStorage.readKeys();
    await keys;
    setState(() {});
  }




  @override
  void initState() {
    fetchKeys();
    homeScreenTrigger.addListener(() {
      fetchKeys();
    });
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
                        builder: (context)=>CustomAlertDialog(
                          title: Text("Force Stop?",style: GoogleFonts.quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.w600
                          ),),
                          content: Text("If you force stop an app, it may misbehave",style: GoogleFonts.quicksand(),),
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
            SliverToBoxAdapter(
              child: Card(
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
                      const CircularProgressIndicator(color: kIconColor,strokeWidth: 2,),
                      Text("Syncing with Cloud",style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w600,
                          fontSize: 20
                      ),),
                    ],
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: keys,
              builder: (BuildContext context, AsyncSnapshot<Map<String,dynamic>> snapshot) {
                if(!snapshot.hasData && !snapshot.hasError){
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(strokeWidth: 2,color: kIconColor,),));
                }
                if(snapshot.hasError || snapshot.data!['businesses'].isEmpty){
                  return const SliverToBoxAdapter(child: Center(child: Text("No data"),));
                }
                return SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    for(int i=0;i<snapshot.data!['businesses'].length;i++)
                      BackupCodeCard(
                        businessName: snapshot.data!['businesses'][i]['businessName'],
                        nickname: snapshot.data!['businesses'][i]['nickname'],
                        keyList: snapshot.data!['businesses'][i]['codes'],
                        lastModified: snapshot.data!['businesses'][i]['lastModified'],
                        secureStorage: secureStorage,
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
