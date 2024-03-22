import 'dart:convert';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  Future<Map<String,dynamic>> _readFullFile() async{
    if(_storage!=null && (jsonDecode(_storage!)['keys']!=null || jsonDecode(_storage!)['encryptionPassword']!=null)){
      return jsonDecode(_storage!);
    }

    try{
      _storage=await _keyStore.read();
      _storage ??= jsonEncode({'keys':{'businesses':[],'lastModified':0}});
      return jsonDecode(_storage!);
    }on AuthException{
      return await _readFullFile();
    }
  }

  Future<void> _writeFullFile(Map<String,dynamic> map) async{
    try{
      map['keys']['version']=(await PackageInfo.fromPlatform()).version;
      String fullDataEncoded=jsonEncode(map);
      await _keyStore.write(fullDataEncoded);
      _storage=fullDataEncoded;
    }on AuthException{
      await _writeFullFile(map);
    }
  }

  Future<String?> readEncryptionPassword() async{
    try{
      return (await _readFullFile())['encryptionPassword'];
    }catch(e){
      return Future.error(e);
    }
  }

  Future<void> writeEncryptionPassword(String password) async{
    Map<String,dynamic> cacheDecoded={};
    try{
      cacheDecoded=await _readFullFile();
      cacheDecoded['encryptionPassword']=password;
    }catch(e){
      cacheDecoded['encryptionPassword']=password;
    }finally{
      cacheDecoded['keys']=await readKeys();
      if(cacheDecoded['keys']['lastModified']!=0){
        cacheDecoded['keys']['lastModified']=DateTime.now().millisecondsSinceEpoch;
      }
      await _writeFullFile(cacheDecoded);
    }
  }

  Future<Map<String,dynamic>?> readUserDetails() async{
    try{
      return (await _readFullFile())['userDetails'];
    }catch(e){
      return Future.error(e);
    }
  }

  Future<String?> readUserProfilePhotoURL() async{
    try{
      Map<String,dynamic>? userDetails=await readUserDetails();
      if(userDetails==null || userDetails['photoURL']==null){
        return null;
      }
      return userDetails['photoURL'];
    }catch(e){
      return Future.error(e);
    }
  }

  Future<String?> readUserID() async{
    try{
      Map<String,dynamic>? userDetails=await readUserDetails();
      if(userDetails==null || userDetails['userID']==null){
        return null;
      }
      return userDetails['userID'];
    }catch(e){
      return Future.error(e);
    }
  }

  Future<void> writeUserDetails(Map<String,dynamic>? userID) async{
    Map<String,dynamic> cacheDecoded={};
    try{
      cacheDecoded=await _readFullFile();
      cacheDecoded['userDetails']=userID;
    }catch(e){
      cacheDecoded['userDetails']=userID;
    }finally{
      await _writeFullFile(cacheDecoded);
    }
  }

  Future<Map<String,dynamic>> readKeys() async{
    Map<String,dynamic> cacheDecoded=await _readFullFile();
    return cacheDecoded['keys'];
  }

  Future<void> addKey(Map<String,dynamic> key) async{
    Map<String,dynamic> cacheDecoded=await _readFullFile();
    cacheDecoded['keys']['businesses'].add(key);
    cacheDecoded['keys']['lastModified']=key['lastModified'];
    await _writeFullFile(cacheDecoded);
  }

  Future<void> modifyKey(Map<String,dynamic> key,int oldLastModified) async{
    Map<String,dynamic> cacheDecoded=await _readFullFile();
    for(int i=0;i<cacheDecoded['keys']['businesses'].length;i++){
      if(cacheDecoded['keys']['businesses'][i]['lastModified']==oldLastModified){
        cacheDecoded['keys']['businesses'][i]=key;
        cacheDecoded['keys']['lastModified']=key['lastModified'];
        break;
      }
    }
    await _writeFullFile(cacheDecoded);
  }

  Future<void> setAllKeys(Map<String,dynamic> keys) async{
    Map<String,dynamic> cacheDecoded=await _readFullFile();
    cacheDecoded['keys']=keys;
    await _writeFullFile(cacheDecoded);
  }

  Future<void> deleteKey(int lastModified,String businessName) async{
    Map<String,dynamic> cacheDecoded=await _readFullFile();

    for(int i=0;i<cacheDecoded['keys']['businesses'].length;i++){
      if(cacheDecoded['keys']['businesses'][i]['lastModified']==lastModified && cacheDecoded['keys']['businesses'][i]['businessName']==businessName){
        cacheDecoded['keys']['businesses'].removeAt(i);
        break;
      }
    }
    cacheDecoded['keys']['lastModified']=DateTime.now().millisecondsSinceEpoch;
    await _writeFullFile(cacheDecoded);
  }
}