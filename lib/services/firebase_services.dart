import 'dart:convert';

import 'package:fallback/const.dart';
import 'package:fallback/enums.dart';
import 'package:fallback/services/encryption_service.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/services/string_services.dart';
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
        throw "Silent Sign In Failed";
      }
    }catch(e){
      googleUser=await GoogleSignIn().signIn();
    }

    final GoogleSignInAuthentication? googleAuth=await googleUser?.authentication;

    final OAuthCredential credential=GoogleAuthProvider.credential(
      idToken: googleAuth?.idToken,
      accessToken: googleAuth?.accessToken,
    );

    if(await _secureStorage.readUserID()!=googleUser?.id){
      await _secureStorage.writeUserID(googleUser!.id);
    }

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOutOfGoogle() async{
    await GoogleSignIn().signOut();
    await _secureStorage.writeUserID(null);
  }

  Future<void> _createCloudBackup() async{
    // DocumentSnapshot document=await _databaseInstance.collection('userData').doc(await _secureStorage.readUserID()).get();
    String? encryptionPassword=await _secureStorage.readEncryptionPassword();
    String? userID=await _secureStorage.readUserID();
    if(encryptionPassword==null || userID==null){
      return;
    }
    Map<String,dynamic> keys=await _secureStorage.readKeys();
    String keysEncrypted=await EncryptionService.encryptString(jsonEncode(keys), (await _secureStorage.readEncryptionPassword())!);

    await _databaseInstance.collection('userData').doc(userID).set({
      "keys" : StringServices.splitStringToList(keysEncrypted, backupStringLengthQuanta),
      "lastModified": keys['lastModified'],
    });
  }

  Future<void> _restoreCloudBackup() async{
    String? encryptionPassword=await _secureStorage.readEncryptionPassword();
    String? userID=await _secureStorage.readUserID();

    if(encryptionPassword==null || userID==null){
      return;
    }

    DocumentSnapshot documentSnapshot=await _databaseInstance.collection('userData').doc(userID).get();

    Map<String,dynamic> document=documentSnapshot.data() as Map<String,dynamic>;
    List<String> keyList=[];
    for(int i=0;i<document['keys'].length;i++){
      keyList.add(document['keys'][i] as String);
    }
    String decryptedKeysString=await EncryptionService.decryptString(StringServices.joinStringFromList(keyList), encryptionPassword);
    _secureStorage.setAllKeys(jsonDecode(decryptedKeysString));

  }

  Future<CloudSyncStatus> checkCloudSyncStatus() async{

    String? userID=await _secureStorage.readUserID();

    if(userID==null){
      throw "USER_NOT_SIGNED_IN";
    }

    DocumentSnapshot documentSnapshot=await _databaseInstance.collection('userData').doc(userID).get();
    int cloudLastUpdated=documentSnapshot.get('lastModified') as int;
    int localLastUpdated=(await _secureStorage.readKeys())['lastModified'];

    if(cloudLastUpdated>localLastUpdated){
      return CloudSyncStatus.cloudLatest;
    }else if(cloudLastUpdated<localLastUpdated){
      return CloudSyncStatus.localLatest;
    }else{
      return CloudSyncStatus.inSync;
    }
  }

  Future<void> performCloudSync() async{
    CloudSyncStatus cloudSyncStatus=await checkCloudSyncStatus();
    if(cloudSyncStatus==CloudSyncStatus.localLatest){
      await _createCloudBackup();
    }else if(cloudSyncStatus==CloudSyncStatus.cloudLatest){
      await _restoreCloudBackup();
    }
  }

}