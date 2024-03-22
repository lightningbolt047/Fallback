import 'dart:async';
import 'dart:isolate';
import 'package:aes256gcm/aes256gcm.dart';

class EncryptionService{

  Future<String> encryptString(String input,String password) async{
    final Completer result=Completer();
    final ReceivePort receivePort=ReceivePort();
    final ReceivePort errorPort=ReceivePort();

    await Isolate.spawn(_encryptStringInIsolate, [receivePort.sendPort,input,password],onError: errorPort.sendPort);

    errorPort.listen((message) {
      result.completeError(message as List);
      errorPort.close();
    });

    receivePort.listen((message) {
      result.complete(message);
      receivePort.close();
    });

    return await result.future;
  }

  static Future<void> _encryptStringInIsolate(List<dynamic> params) async{
    SendPort sendPort=params[0] as SendPort;
    Isolate.exit(sendPort,await Aes256Gcm.encrypt(params[1],params[2]));
  }

  Future<String> decryptString(String cypher,String password) async{
    final Completer result=Completer();
    final ReceivePort receivePort=ReceivePort();
    final ReceivePort errorPort=ReceivePort();

    await Isolate.spawn(_decryptStringInIsolate, [receivePort.sendPort,cypher,password],onError: errorPort.sendPort);

    errorPort.listen((message) {
      errorPort.close();
      result.completeError(message as List);
    });

    receivePort.listen((message) {
      receivePort.close();
      result.complete(message);
    });

    return await result.future;
  }

  static Future<void> _decryptStringInIsolate(List<dynamic> params) async{
    SendPort sendPort=params[0] as SendPort;
    Isolate.exit(sendPort,await Aes256Gcm.decrypt(params[1], params[2]));
  }

}