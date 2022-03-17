import 'dart:convert';

import 'package:fallback/const.dart';
import 'package:fallback/services/encryptionService.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/services/stirng_services.dart';
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

  Future<void> createCloudBackup() async{
    // DocumentSnapshot document=await _databaseInstance.collection('userData').doc(await _secureStorage.readUserID()).get();
    print((await _databaseInstance.collection('userData').get()));
    String? encryptionPassword=await _secureStorage.readEncryptionPassword();
    String? userID=await _secureStorage.readUserID();
    if(encryptionPassword==null || userID==null){
      return;
    }

    String keysEncrypted=await EncryptionService.encryptString(jsonEncode(await _secureStorage.readKeys()), (await _secureStorage.readEncryptionPassword())!);

    await _databaseInstance.collection('userData').doc(await _secureStorage.readUserID()).set({
      "keys" : StringServices.splitStringToList(keysEncrypted, backupStringLengthQuanta),
      "lastModified": DateTime.now().millisecondsSinceEpoch
    });

  }

}