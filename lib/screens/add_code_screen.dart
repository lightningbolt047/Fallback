import 'package:fallback/const.dart';
import 'package:fallback/enums.dart';
import 'package:fallback/services/secure_storage.dart';
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
  final VoidCallback onSuccess;
  final String? businessName;
  final String? nickname;
  final List<List<String>>? codes;

  const AddCodeScreen({Key? key,required this.secureStorage, required this.onSuccess,this.businessName,this.nickname,this.codes}) : super(key: key);

  @override
  State<AddCodeScreen> createState() => _AddCodeScreenState(secureStorage,onSuccess,businessName,nickname,codes);
}

class _AddCodeScreenState extends State<AddCodeScreen> {

  final SecureStorage secureStorage;
  final VoidCallback onSuccess;
  final String? _businessName;
  final String? _nickname;
  final List<List<String>>? codes;

  _AddCodeScreenState(this.secureStorage,this.onSuccess,this._businessName,this._nickname,this.codes);


  late final TextEditingController _businessNameInputController;
  late final TextEditingController _nicknameInputController;
  List<List<TextEditingController>> _codeInputControllers=[];

  List<TextEditingController> _codeInputControllersToDispose=[];

  String _businessIconPath="no_company.png";
  late int _numCols;
  late int _numRows;

  // List<List<String>> codes=[];



  void initializeInputControllers(){
    if(codes!=null){
      _numRows=codes!.length;
      _numCols=codes![0].length;
      for(int i=0;i<_numRows;i++){
        _codeInputControllers.add([]);
        for(int j=0;j<_numCols;j++){
          _codeInputControllers[i].add(TextEditingController(text: codes![i][j]));
        }
      }
    }else{
      _numRows=_numCols=2;
      for(int i=0;i<_numRows;i++){
        _codeInputControllers.add([]);
        for(int j=0;j<_numCols;j++){
          _codeInputControllers[i].add(TextEditingController());
        }
      }
    }
    _businessIconPath=AssetMapping.getBusinessIconPath(_businessName??"");
    _businessNameInputController=TextEditingController(text: _businessName);
    _nicknameInputController=TextEditingController(text: _nickname);
  }

  void addRowCodes(){
    // List<String> newRow=[for(int i=0;i<_numCols;i++)""];
    List<TextEditingController> newRow=[];
    for(int i=0;i<_numCols;i++){
      if(_codeInputControllersToDispose.isNotEmpty){
        newRow.add(_codeInputControllersToDispose.removeLast());
      }else{
        newRow.add(TextEditingController());
      }
    }
    _codeInputControllers.add(newRow);
  }

  void removeRowCodes(){
    for(int i=0;i<_codeInputControllers.last.length;i++){
      _codeInputControllers.last[i].text="";
      _codeInputControllersToDispose.add(_codeInputControllers.last[i]);
    }
    _codeInputControllers.removeLast();
  }

  void addColumnCodes(){
    for(int i=0;i<_codeInputControllers.length;i++){
      if(_codeInputControllersToDispose.isNotEmpty){
        _codeInputControllers[i].add(_codeInputControllersToDispose.removeLast());
      }else{
        _codeInputControllers[i].add(TextEditingController());
      }
    }
  }

  void removeColumnCodes(){
    for(int i=0;i<_codeInputControllers.length;i++){
      _codeInputControllers[i].last.text="";
      _codeInputControllersToDispose.add(_codeInputControllers[i].removeLast());
    }
  }

  @override
  void initState() {
    initializeInputControllers();
    super.initState();
  }

  @override
  void dispose() {
    for(int i=0;i<_codeInputControllersToDispose.length;i++){
      _codeInputControllersToDispose[i].dispose();
    }
    _codeInputControllersToDispose.clear();
    super.dispose();
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
              onPressed: () async {

                if(_businessNameInputController.text==""){
                  showDialog(
                    context: context,
                    builder: (context)=>YouAlertDialog(
                      title: const Text("Error",style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                      ),),
                      backgroundColor: kBackgroundColor,
                      content: const Text("Business Name cannot be empty"),
                      actions: [
                        CustomMaterialButton(
                          buttonColor: kIconColor,
                          child: const Text("OK",style: TextStyle(
                            color: kBackgroundColor
                          ),),
                          onPressed: (){
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  );
                  return;
                }


                List<List<String>> codes=[];
                for(int i=0;i<_numRows;i++){
                  codes.add([]);
                  for(int j=0;j<_numCols;j++){
                    codes[i].add(_codeInputControllers[i][j].text);
                  }
                }
                Map<String,dynamic> key={};
                key['businessName']=_businessNameInputController.text;
                key['businessIconPath']=_businessIconPath;
                key['nickname']=_nicknameInputController.text;
                key['codes']=codes;
                key['lastModified']=DateTime.now().millisecondsSinceEpoch;
                try{
                  await secureStorage.addKey(key);
                  Navigator.pop(context);
                  onSuccess();
                  // homeScreenTrigger.triggerHomeScreenUpdate();
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
                    controller: _businessNameInputController,
                    onChanged: (value){
                      String _newBusinessIconPath=AssetMapping.getBusinessIconPath(value);
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
                    controller: _nicknameInputController,
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
                                  controller: _codeInputControllers[i][j],
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
