import 'package:fallback/const.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/utils/home_screen_trigger.dart';
import 'package:fallback/widgets_basic/buttons/custom_material_button.dart';
import 'package:flutter/material.dart';
import 'package:fallback/services/asset_mapping.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const.dart';
import 'code_segment.dart';
import 'material_you/custom_alert_dialog.dart';

class BackupCodeCard extends StatefulWidget {
  final String businessName;
  final String nickname;
  final List<dynamic> keyList;
  final int lastModified;
  final SecureStorage secureStorage;
  const BackupCodeCard({Key? key, required this.businessName, required this.nickname, required this.keyList,required this.lastModified, required this.secureStorage}) : super(key: key);

  @override
  State<BackupCodeCard> createState() => _BackupCodeCardState(businessName,nickname,keyList,lastModified,secureStorage);
}

class _BackupCodeCardState extends State<BackupCodeCard> with SingleTickerProviderStateMixin {

  final String businessName;
  final String nickname;
  final List<dynamic> keyList;
  final int lastModified;
  final SecureStorage secureStorage;

  _BackupCodeCardState(this.businessName,this.nickname,this.keyList,this.lastModified,this.secureStorage);


  bool _isExpanded=false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;


  @override
  void initState() {
    _controller=AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500)
    );

    _fadeAnimation=Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));


    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      color: kItemColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  if(_isExpanded){
                    _controller.reverse(from: 1);
                  }else{
                    _controller.forward(from: 0);
                  }
                  _isExpanded=!_isExpanded;
                });
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 16,
                    child: Image.asset("assets/business_icons/${AssetMapping.getBusinessIconPath(businessName)}",fit: BoxFit.fill,),
                  ),
                  const SizedBox(width: 6,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(businessName,style: GoogleFonts.quicksand(
                          fontSize: 24,
                          fontWeight: FontWeight.w400
                      ),),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width*0.6,
                        ),
                        child: Text(nickname,maxLines: 1,overflow: TextOverflow.ellipsis,style: GoogleFonts.quicksand(),),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AnimatedCrossFade(
                    firstChild: const Icon(Icons.visibility_rounded,color: kIconColor,),
                    secondChild: const Icon(Icons.visibility_off_rounded,color: kIconColor,),
                    crossFadeState: _isExpanded?CrossFadeState.showSecond:CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                  // Icon(_isExpanded?Icons.visibility_off_rounded:Icons.visibility_rounded,color: kIconColor,),
                  // const SizedBox(width: 8,)
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
              child: Builder(
                builder: (BuildContext context){
                  if(_isExpanded){
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for(int i=0;i<keyList.length;i++)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  for(int j=0;j<keyList[i].length;j++)
                                    CodeSegment(codeSegment: keyList[i][j]),
                                ],
                              ),
                            )
                        ],
                      ),
                    );
                  }
                  return Container();

                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomMaterialButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy_rounded),
                      const SizedBox(width: 8,),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeIn,
                        child: Builder(
                          builder: (context){
                            if(_isExpanded){
                              return const Text("Copy");
                            }
                            return const Text("Copy to clipboard");
                          },
                        ),
                      ),
                    ],
                  ),
                  onPressed: (){
                    String toClipboard="";
                    for(int i=0;i<keyList.length;i++){
                      for(int j=0;j<keyList[i].length;j++){
                        toClipboard+=keyList[i][j];
                        if(j<keyList[i].length-1){
                          toClipboard+="\t";
                        }
                      }
                      if(i<keyList.length-1){
                        toClipboard+="\n";
                      }
                    }
                    Clipboard.setData(ClipboardData(text: toClipboard));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied code to clipboard")));
                  },
                ),
                CustomMaterialButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.edit),
                      SizedBox(width: 8,),
                      Text("Edit code"),
                    ],
                  ),
                  onPressed: (){},
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeIn,
                  child: Builder(
                    builder: (context) {
                      if(_isExpanded){
                        return CustomMaterialButton(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.delete_forever_rounded),
                              SizedBox(width: 8,),
                              Text("Delete"),
                            ],
                          ),
                          onPressed: (){
                            showDialog(
                              context: context,
                              builder: (context)=>CustomAlertDialog(
                                title: const Text("Are you sure?",style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                                ),),
                                backgroundColor: kBackgroundColor,
                                content: const Text("This will delete this key permanently and the change will be reflected in your cloud storage as well (if you are signed in)",),
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
                                    child: Text("OK",style: GoogleFonts.quicksand(color: kBackgroundColor),),
                                    buttonColor: kIconColor,
                                    onPressed: () async{
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      try{
                                        await secureStorage.deleteKey(lastModified, businessName);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted key successfully")));
                                        Navigator.pop(context);
                                        homeScreenTrigger.triggerHomeScreenUpdate();
                                      }catch(e){
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete key")));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return Container();
                    }
                  ),
                ),
              ],
            ),
            // SizedBox(
            //   height: 8,
            // )
          ],
        ),
      ),
    );
  }
}
