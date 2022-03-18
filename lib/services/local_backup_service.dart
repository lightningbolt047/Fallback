import 'dart:convert';
import 'package:aes256gcm/aes256gcm.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalBackupService{
  final SecureStorage secureStorage;
  LocalBackupService(this.secureStorage);

  Future<String> backupAllKeys() async{
    try{
      String directoryPath=(await getExternalStorageDirectory())!.path;
      Map<String,dynamic> keys=await secureStorage.readKeys();
      String keysEncoded=jsonEncode(keys);
      String encrypted=await Aes256Gcm.encrypt(keysEncoded, (await secureStorage.readEncryptionPassword())!);
      String fullFilePath=path.join(directoryPath,"Fallback-backup-${DateTime.now().millisecondsSinceEpoch}.fbcrypt");
      File file=File(fullFilePath);
      await file.writeAsString(encrypted);
      return fullFilePath;
    }catch(e){
      return Future.error(e);
    }
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