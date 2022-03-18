import 'package:fallback/const.dart';
import 'package:fallback/enums.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/utils/home_screen_trigger.dart';
import 'package:fallback/widgets_basic/buttons/custom_material_button.dart';
import 'package:fallback/widgets_basic/compound/counter_toggle.dart';
import 'package:fallback/widgets_basic/input_widgets/code_segment_input.dart';
import 'package:fallback/widgets_basic/material_you/you_alert_dialog.dart';
import 'package:fallback/widgets_basic/text_widgets/screen_header_text.dart';
import 'package:flutter/material.dart';
import '../services/asset_mapping.dart';
import '../widgets_basic/input_widgets/custom_text_field.dart';

class AddCodeScreen extends StatefulWidget {

  final SecureStorage secureStorage;

  const AddCodeScreen({Key? key,required this.secureStorage,}) : super(key: key);

  @override
  State<AddCodeScreen> createState() => _AddCodeScreenState(secureStorage,);
}

class _AddCodeScreenState extends State<AddCodeScreen> {

  final SecureStorage secureStorage;

  _AddCodeScreenState(this.secureStorage,);



  String _businessName="";
  String _nickname="";
  String _businessIconPath="no_company.png";
  int _numCols=2;
  int _numRows=2;

  List<List<String>> codes=[];



  void initializeCodesList(){
    for(int i=0;i<_numRows;i++){
      codes.add([]);
      for(int j=0;j<_numCols;j++){
        codes[i].add("");
      }
    }
  }

  void addRowCodes(){
    List<String> newRow=[for(int i=0;i<_numCols;i++)""];
    codes.add(newRow);
  }

  void removeRowCodes(){
    codes.removeLast();
  }

  void addColumnCodes(){
    for(int i=0;i<codes.length;i++){
      codes[i].add("");
    }
  }

  void removeColumnCodes(){
    for(int i=0;i<codes.length;i++){
      codes[i].removeLast();
    }
  }

  @override
  void initState() {
    initializeCodesList();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: kIconColor
        ),
        actionsIconTheme: const IconThemeData(
          color: kIconColor
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: kBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
              child: const Text("Save",style: TextStyle(color: kBackgroundColor,),),
              buttonColor: kIconColor,
              onPressed: ()async{
                Map<String,dynamic> key={};
                key['businessName']=_businessName;
                key['businessIconPath']=_businessIconPath;
                key['nickname']=_nickname;
                key['codes']=codes;
                key['lastModified']=DateTime.now().millisecondsSinceEpoch;
                try{
                  await secureStorage.addKey(key);
                  Navigator.pop(context);
                  homeScreenTrigger.triggerHomeScreenUpdate();
                }catch(e){
                  showDialog(
                    context: context,
                    builder: (context)=>YouAlertDialog(
                      backgroundColor: kBackgroundColor,
                      title: const Text("Error",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
                      content: const Text("An error occurred while storing the information"),
                      actions: [
                        CustomMaterialButton(
                          child: const Text("OK",style: TextStyle(color: kBackgroundColor),),
                          buttonColor: kIconColor,
                          onPressed: (){
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ScreenHeaderText(text: "Add 2FA Backup Key"),
              const SizedBox(
                height: 100,
              ),
              Column(
                children: [
                  CustomTextField(
                    labelText: "App Name",
                    filled: true,
                    prefix: Row(
                      children: [
                        const SizedBox(width: 4,),
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 16,
                          child: Image.asset("assets/business_icons/$_businessIconPath",fit: BoxFit.fill,),
                        ),
                        const SizedBox(width: 4,)
                      ],
                    ),
                    onChanged: (value){
                      _businessName=value;
                      String _newBusinessIconPath=AssetMapping.getBusinessIconPath(_businessName);
                      if(_businessIconPath!=_newBusinessIconPath){
                        setState(() {
                          _businessIconPath=_newBusinessIconPath;
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  CustomTextField(
                    labelText: "Account nickname",
                    filled: true,
                    onChanged: (value){
                      _nickname=value;
                    },
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Rows",style: TextStyle(
                        fontSize: 20
                      ),),
                      CounterToggle(
                        value: _numRows,
                        onTogglePress: (CounterAction action){
                          if(action==CounterAction.subtract && !(_numRows<2)){
                            setState(() {
                              removeRowCodes();
                              _numRows--;
                            });
                            return;
                          }else if(action==CounterAction.add){
                            setState(() {
                              addRowCodes();
                              _numRows++;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Columns",style: TextStyle(
                          fontSize: 20
                      ),),
                      CounterToggle(
                        value: _numCols,
                        onTogglePress: (CounterAction action){
                          if(action==CounterAction.subtract && !(_numCols<2)){
                            setState(() {
                              removeColumnCodes();
                              _numCols--;
                            });
                            return;
                          }else if(action==CounterAction.add){
                            setState(() {
                              addColumnCodes();
                              _numCols++;
                            });
                          }

                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 18,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for(int i=0;i<_numRows;i++)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              for(int j=0;j<_numCols;j++)
                                CodeSegmentInput(
                                  isLastField: (i==_numRows-1 && j==_numCols-1),
                                  onChanged:(value){
                                    codes[i][j]=value;
                                  }
                                ),
                            ],
                          ),
                        )
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
