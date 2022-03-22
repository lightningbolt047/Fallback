import 'dart:convert';

import 'package:fallback/const.dart';
import 'package:fallback/enums.dart';
import 'package:fallback/services/encryption_service.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/services/string_services.dart';
import 'package:fallback/widgets_basic/buttons/custom_material_button.dart';
import 'package:fallback/widgets_basic/material_you/you_alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices{

  late final SecureStorage _secureStorage;
  late final FirebaseFirestore _databaseInstance;

  FirebaseServices(SecureStorage secureStorage){
    _secureStorage=secureStorage;
    _databaseInstance=FirebaseFirestore.instance;
  }

  Future<UserCredential> signInWithGoogle() async{

    GoogleSignInAccount? googleUser;

    try{
      googleUser=await GoogleSignIn().signInSilently();
      if(googleUser==null){
        throw "SILENT_SIGN_IN_FAILED";
      }
    }catch(e){
      googleUser=await GoogleSignIn().signIn();
    }

    final GoogleSignInAuthentication? googleAuth=await googleUser?.authentication;

    final OAuthCredential credential=GoogleAuthProvider.credential(
      idToken: googleAuth?.idToken,
      accessToken: googleAuth?.accessToken,
    );

    Map<String,dynamic>? currentUserDetails=await _secureStorage.readUserDetails();

    if(currentUserDetails==null || currentUserDetails['userID']!=googleUser?.id){
      currentUserDetails={
        "userID":googleUser!.id,
        "displayName":googleUser.displayName,
        "photoURL":googleUser.photoUrl,
      };
      await _secureStorage.writeUserDetails(currentUserDetails);
    }

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOutOfGoogle() async{
    await _secureStorage.writeUserDetails(null);
    await GoogleSignIn().signOut();
  }

  Future<CloudSyncStatus> _createCloudBackup() async{
    String? encryptionPassword=await _secureStorage.readEncryptionPassword();
    Map<String,dynamic>? userDetails=await _secureStorage.readUserDetails();

    if(encryptionPassword==null){
      return CloudSyncStatus.encryptionPasswordNotSet;
    }
    if(userDetails==null || userDetails['userID']==null){
      return CloudSyncStatus.notSignedIn;
    }

    try{
      Map<String,dynamic> keys=await _secureStorage.readKeys();
      String keysEncrypted=await EncryptionService.encryptString(jsonEncode(keys), (await _secureStorage.readEncryptionPassword())!);

      await _databaseInstance.collection('userData').doc(userDetails['userID']).set({
        "keys" : StringServices.splitStringToList(keysEncrypted, backupStringLengthQuanta),
        "lastModified": keys['lastModified'],
      });

      return CloudSyncStatus.success;
    }catch(e){
      return CloudSyncStatus.networkError;
    }

  }

  Future<CloudSyncStatus> _restoreCloudBackup() async{
    String? encryptionPassword=await _secureStorage.readEncryptionPassword();
    Map<String,dynamic>? userDetails=await _secureStorage.readUserDetails();

    if(encryptionPassword==null){
      return CloudSyncStatus.encryptionPasswordNotSet;
    }
    if(userDetails==null || userDetails['userID']==null){
      return CloudSyncStatus.notSignedIn;
    }

    try{
      DocumentSnapshot documentSnapshot=await _databaseInstance.collection('userData').doc(userDetails['userID']).get();

      Map<String,dynamic> document=documentSnapshot.data() as Map<String,dynamic>;
      List<String> keyList=[];
      for(int i=0;i<document['keys'].length;i++){
        keyList.add(document['keys'][i] as String);
      }
      late String decryptedKeysString;
      try{
        decryptedKeysString=await EncryptionService.decryptString(StringServices.joinStringFromList(keyList), encryptionPassword);
      }catch(e){
        return CloudSyncStatus.wrongEncryptionPassword;
      }
      _secureStorage.setAllKeys(jsonDecode(decryptedKeysString));

      return CloudSyncStatus.success;
    }catch(e){
      return CloudSyncStatus.networkError;
    }

  }

  Future<CloudSyncType> checkCloudSyncRequired() async{

    try{
      Map<String,dynamic>? userDetails=await _secureStorage.readUserDetails();

      if(userDetails==null || userDetails['userID']==null){
        return Future.error("USER_NOT_SIGNED_IN");
      }

      DocumentSnapshot documentSnapshot=await _databaseInstance.collection('userData').doc(userDetails['userID']).get();
      int cloudLastUpdated=documentSnapshot.get('lastModified') as int;
      int localLastUpdated=(await _secureStorage.readKeys())['lastModified'];

      if(cloudLastUpdated>localLastUpdated){
        return CloudSyncType.cloudLatest;
      }else if(cloudLastUpdated<localLastUpdated){
        return CloudSyncType.localLatest;
      }else{
        return CloudSyncType.inSync;
      }
    }catch(e){
      return Future.error("NETWORK_CONNECTION_ERROR");
    }
  }

  Future<CloudSyncStatus> performCloudSync(BuildContext context) async{

    String? encryptionPassword=await _secureStorage.readEncryptionPassword();
    Map<String,dynamic>? userDetails=await _secureStorage.readUserDetails();

    if(userDetails==null || userDetails['userID']==null){
      return CloudSyncStatus.notSignedIn;
    }
    if(encryptionPassword==null){
      return CloudSyncStatus.encryptionPasswordNotSet;
    }


    CloudSyncType cloudSyncStatus=await checkCloudSyncRequired();
    if(cloudSyncStatus==CloudSyncType.localLatest){
      return await _createCloudBackup();
    }else if(cloudSyncStatus==CloudSyncType.cloudLatest){
      late CloudSyncStatus syncResult;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context)=>YouAlertDialog(
          title: const Text("Restore?",style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),),
          backgroundColor: kBackgroundColor,
          content: const Text("A newer version of the backup was found online. Restore? If you don't restore now, the data will be overwritten by another backup and can never be retrieved."),
          actions: [
            OutlinedButton(
              onPressed: (){
                syncResult=CloudSyncStatus.userCancelled;
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
              child: const Text("OK",style: TextStyle(
                color: kBackgroundColor
              ),),
              onPressed: () async{
                syncResult=await _restoreCloudBackup();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context)=>YouAlertDialog(
                    title: Text("Restore ${syncResult==CloudSyncStatus.success?"success":"failed"}",style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),),
                    backgroundColor: kBackgroundColor,
                    content: Text(syncResult==CloudSyncStatus.success?"Restore successful! Now restart app to continue usage":syncResult==CloudSyncStatus.wrongEncryptionPassword?"Set your old encryption password as your current encryption password and try again":"Failed to restore cloud backup"),
                    actions: [
                      if(syncResult!=CloudSyncStatus.success)
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
              buttonColor: kIconColor,
            ),
          ],
        ),
      );
      return syncResult;
    }
    return CloudSyncStatus.success;
  }

}