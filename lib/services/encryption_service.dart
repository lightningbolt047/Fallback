import 'package:aes256gcm/aes256gcm.dart';

class EncryptionService{

  static Future<String> encryptString(String input,String password) async{
    return await Aes256Gcm.encrypt(input, password);
  }

  static Future<String> decryptString(String cypher,String password) async{
    return await Aes256Gcm.decrypt(cypher, password);
  }

}