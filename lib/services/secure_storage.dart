import 'dart:convert';

import 'package:biometric_storage/biometric_storage.dart';

class SecureStorage{

  late final BiometricStorage _biometricStorage;
  late final BiometricStorageFile _keyStore;

  String? _storage;

  SecureStorage(this._biometricStorage,this._keyStore,);

  static Future<SecureStorage> getInstance() async{
    BiometricStorage _biometricStorage=BiometricStorage();
    BiometricStorageFile _keyStore=await _biometricStorage.getStorage("keyStore");
    return SecureStorage(_biometricStorage, _keyStore);
  }

  Future<CanAuthenticateResponse> getBiometricStatus() async{
    return await _biometricStorage.canAuthenticate();
  }

  Future<Map<String,dynamic>> readFullFile() async{

    if(_storage!=null && (jsonDecode(_storage!)['keys']!=null || jsonDecode(_storage!)['encryptionPassword']!=null)){
      return jsonDecode(_storage!);
    }

    try{
      _storage=await _keyStore.read();
      _storage ??= jsonEncode({'keys':{'businesses':[],'lastModified':0}});
      return jsonDecode(_storage!);
    }on AuthException{
      return await readFullFile();
    }
  }

  Future<void> writeFullFile(Map<String,dynamic> map) async{
    try{
      String fullDataEncoded=jsonEncode(map);
      await _keyStore.write(fullDataEncoded);
      _storage=fullDataEncoded;
    }on AuthException{
      await writeFullFile(map);
    }
  }

  Future<String?> readEncryptionPassword() async{
    try{
      return (await readFullFile())['encryptionPassword'];
    }catch(e){
      return Future.error(e);
    }
  }

  Future<void> writeEncryptionPassword(String password) async{
    Map<String,dynamic> cacheDecoded={};
    try{
      cacheDecoded=await readFullFile();
      cacheDecoded['encryptionPassword']=password;
    }catch(e){
      cacheDecoded['encryptionPassword']=password;
    }finally{
      await writeFullFile(cacheDecoded);
    }
  }

  Future<String?> readUserID() async{
    try{
      return (await readFullFile())['userID'];
    }catch(e){
      return Future.error(e);
    }
  }

  Future<void> writeUserID(String? userID) async{
    Map<String,dynamic> cacheDecoded={};
    try{
      cacheDecoded=await readFullFile();
      cacheDecoded['userID']=userID;
    }catch(e){
      cacheDecoded['userID']=userID;
    }finally{
      await writeFullFile(cacheDecoded);
    }
  }

  Future<Map<String,dynamic>> readKeys() async{
    Map<String,dynamic> cacheDecoded=await readFullFile();
    return cacheDecoded['keys'];
  }

  Future<void> addKey(Map<String,dynamic> key) async{
    Map<String,dynamic> cacheDecoded=await readFullFile();
    cacheDecoded['keys']['businesses'].add(key);
    cacheDecoded['keys']['lastModified']=key['lastModified'];
    await writeFullFile(cacheDecoded);
  }

  Future<void> setAllKeys(Map<String,dynamic> keys) async{
    Map<String,dynamic> cacheDecoded=await readFullFile();
    cacheDecoded['keys']=keys;
    await writeFullFile(cacheDecoded);
  }

  Future<void> deleteKey(int lastModified,String businessName) async{
    Map<String,dynamic> cacheDecoded=await readFullFile();

    for(int i=0;i<cacheDecoded['keys']['businesses'].length;i++){
      if(cacheDecoded['keys']['businesses'][i]['lastModified']==lastModified && cacheDecoded['keys']['businesses'][i]['businessName']==businessName){
        cacheDecoded['keys']['businesses'].removeAt(i);
        break;
      }
    }
    cacheDecoded['keys']['lastModified']=DateTime.now().millisecondsSinceEpoch;
    await writeFullFile(cacheDecoded);
  }




























  // Future<void> writeToStorage(Map<String,dynamic> map) async{
  //   try{
  //     String encoded=jsonEncode(map);
  //     await _keyStore.write(encoded);
  //     _storage=jsonEncode(encoded);
  //   }on AuthException{
  //     await writeToStorage(map);
  //   }
  // }
  //
  // Future<Map<String,dynamic>> readFromStorage() async{
  //   dynamic decodedStorage=jsonDecode(_storage!);
  //   if(_storage!=null && (jsonDecode(_storage!)['keyDetails']!=null || jsonDecode(_storage!)['encryptionPassword']!=null)){
  //     return jsonDecode(_storage!);
  //   }
  //
  //   try{
  //     _storage=await _keyStore.read();
  //     if(_storage==null){
  //       throw Exception("Empty");
  //     }
  //     return jsonDecode(_storage!);
  //   }on AuthException{
  //     return await readFromStorage();
  //   }
  // }
  //
  // Future<Map<String,dynamic>> readKeys() async{
  //   try{
  //     return (await readFromStorage())['keyDetails'];
  //   }catch(e,stackTrace){
  //     print(stackTrace);
  //     return Future.error(e.toString());
  //   }
  // }
  //
  // Future<Map<String,String>> readEncryptionPassword() async{
  //   try{
  //     return (await readFromStorage())['encryptionPassword'];
  //   }catch(e){
  //     return Future.error(e.toString());
  //   }
  // }
  //
  // Future<void> writeKeys(dynamic keys) async{
  //   if(_storage==null){
  //     Map<String,dynamic> keysToStore={};
  //     keysToStore['keyDetails']={};
  //     keysToStore['keyDetails']['keys']=keys;
  //     DateTime now=DateTime.now();
  //     keysToStore['keyDetails']['lastModified']=now.millisecondsSinceEpoch;
  //     await writeToStorage(keysToStore);
  //   }else{
  //     Map<String,dynamic> decoded=jsonDecode(_storage!);
  //     decoded['keyDetails']['keys']=keys;
  //     decoded['keyDetails']['lastModified']=DateTime.now().millisecondsSinceEpoch;
  //     await writeToStorage(decoded);
  //   }
  // }
  //
  // Future<void> addKey(Map<String,dynamic> key) async{
  //   Map<String,dynamic> keyDetails={'keys':[]};
  //   try{
  //     keyDetails=await readKeys();
  //     keyDetails['keys'].add(key);
  //   }catch(e){
  //     keyDetails['keys'].add(key);
  //   }finally{
  //     await writeKeys(keyDetails['keys']);
  //   }
  // }
  //
  // Future<void> writeEncryptionPassword(String password) async{
  //   if(_storage==null){
  //     Map<String,dynamic> storage={};
  //     storage['encryptionPassword']=password;
  //     await writeToStorage(storage);
  //   }else{
  //     Map<String,dynamic> decoded=jsonDecode(_storage!);
  //     decoded['encryptionPassword']=password;
  //     await writeToStorage(decoded);
  //   }
  // }

}