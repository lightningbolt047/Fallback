import 'dart:convert';
import 'package:aes256gcm/aes256gcm.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class LocalBackupService{
  final SecureStorage secureStorage;
  LocalBackupService(this.secureStorage);

  Future<void> backupAllKeys(String directoryPath) async{
    try{
      Map<String,dynamic> keys=await secureStorage.readKeys();
      String keysEncoded=jsonEncode(keys);
      String encrypted=await Aes256Gcm.encrypt(keysEncoded, (await secureStorage.readEncryptionPassword())!);
      File file=File(path.join(directoryPath,"Fallback-backup-${DateTime.now().millisecondsSinceEpoch}.fbcrypt"));
      await file.writeAsString(encrypted);
    }catch(e){
      return Future.error(e);
    }
  }

}