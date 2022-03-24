import 'dart:convert';
import 'package:fallback/const.dart';
import 'package:fallback/services/encryption_service.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/widgets_basic/buttons/custom_material_button.dart';
import 'package:fallback/widgets_basic/material_you/you_alert_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets_basic/compound/restore_progress_dialog.dart';
import '../widgets_basic/input_widgets/custom_text_field.dart';

class LocalBackupService{
  final SecureStorage secureStorage;
  late final EncryptionService _encryptionService;
  LocalBackupService(this.secureStorage){
    _encryptionService=EncryptionService();
  }

  Future<String> backupAllKeys() async{
    try{
      String directoryPath=(await getExternalStorageDirectory())!.path;
      Map<String,dynamic> keys=await secureStorage.readKeys();
      String keysEncoded=jsonEncode(keys);
      String encrypted=await _encryptionService.encryptString(keysEncoded, (await secureStorage.readEncryptionPassword())!);
      String fullFilePath=path.join(directoryPath,"Fallback-backup-${DateTime.now().millisecondsSinceEpoch}.fbcrypt");
      File file=File(fullFilePath);
      await file.writeAsString(encrypted);
      return fullFilePath;
    }catch(e){
      return Future.error(e);
    }
  }

  Future<void> restoreAllKeys(BuildContext context) async{
    FilePickerResult? filePickerResult=await FilePicker.platform.pickFiles(dialogTitle: "Choose backup file location",type: FileType.any,);
    if(filePickerResult==null){
      return;
    }
    String filePath=filePickerResult.files[0].path!;
    if(!filePath.endsWith(".fbcrypt")){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context)=>YouAlertDialog(
          title: const Text("Invalid File",style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),),
          backgroundColor: kBackgroundColor,
          content: const Text("You must select a .fbcrypt file to restore a backup"),
          actions: [
            CustomMaterialButton(
              child: const Text("OK",style: TextStyle(
                color: kBackgroundColor
              ),),
              buttonColor: kIconColor,
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      return;
    }
    File file=File(filePath);
    String encryptedKeys=await file.readAsString();

    String password="";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context)=>YouAlertDialog(
        title: const Text("Encryption Password",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,),),
        content: CustomTextField(
          onChanged: (value){
            password=value;
          },
          obscureText: true,
          filled: true,
          labelText: "Password",
        ),
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
            child: const Text("OK",style: TextStyle(color: kBackgroundColor),),
            buttonColor: kIconColor,
            onPressed: () async{
              BuildContext previousDialogContext=context;
              showDialog(
                context: context,
                builder: (context)=>FutureBuilder(
                    future: _encryptionService.decryptString(encryptedKeys, password),
                    builder: (BuildContext context,AsyncSnapshot<String> snapshot) {

                      if(snapshot.connectionState==ConnectionState.waiting){
                        return const RestoreProgressDialog();
                      }

                      if(snapshot.hasError){
                        return YouAlertDialog(
                          title: const Text("Decryption Failed",style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),),
                          backgroundColor: kBackgroundColor,
                          content: const Text("Please input the correct password to decrypt the backup. The backup would have been encrypted with a password you had set earlier"),
                          actions: [
                            CustomMaterialButton(
                              child: const Text("OK",style: TextStyle(
                                  color: kBackgroundColor
                              ),),
                              buttonColor: kIconColor,
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      }

                      return FutureBuilder(
                          future: secureStorage.setAllKeys(jsonDecode(snapshot.data!)),
                          builder: (BuildContext context,AsyncSnapshot<void> snapshot) {
                            if(snapshot.connectionState==ConnectionState.waiting){
                              return const RestoreProgressDialog();
                            }

                            if(snapshot.hasError){
                              return YouAlertDialog(
                                title: const Text("Restore Failed",style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),),
                                backgroundColor: kBackgroundColor,
                                content: const Text("Restore failed for an unknown reason"),
                                actions: [
                                  CustomMaterialButton(
                                    child: const Text("OK",style: TextStyle(
                                        color: kBackgroundColor
                                    ),),
                                    buttonColor: kIconColor,
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            }

                            return YouAlertDialog(
                              title: const Text("Backup Restored",style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),),
                              content: const Text("Backup restored successfully"),
                              backgroundColor: kBackgroundColor,
                              actions: [
                                CustomMaterialButton(
                                  child: const Text("OK",style: TextStyle(
                                    color: kBackgroundColor,
                                  ),),
                                  buttonColor: kIconColor,
                                  onPressed: (){
                                    Navigator.pop(context);
                                    Navigator.pop(previousDialogContext);
                                  },
                                ),
                              ],
                            );
                          }
                      );
                    }
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteAllBackups() async{
    Directory directoryPath=(await getExternalStorageDirectory())!;
    if(await directoryPath.exists()){
      List<FileSystemEntity> fsEntities=directoryPath.listSync(followLinks: false);
      for(FileSystemEntity entity in fsEntities){
        if(entity is File && entity.path.split("/").last.contains(".fbcrypt")){
          await entity.delete();
        }
      }
    }
  }
}
