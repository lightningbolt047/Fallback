import 'dart:convert';
import 'dart:isolate';

class JsonService{

  Future<String> encode(dynamic object) async{
    ReceivePort receivePort=ReceivePort();
    await Isolate.spawn(_encodeInIsolate, [receivePort.sendPort,object]);
    return await receivePort.first;
  }

  void _encodeInIsolate(List<dynamic> params){
    final String jsonEncoded=jsonEncode(params[1]);
    SendPort sendPort=params[0] as SendPort;
    Isolate.exit(sendPort,jsonEncoded);
  }

  Future<dynamic> decode(String jsonEncoded) async{
    ReceivePort receivePort=ReceivePort();
    await Isolate.spawn(_decodeInIsolate, [receivePort.sendPort,jsonEncoded]);
    return await receivePort.first;
  }

  void _decodeInIsolate(List<dynamic> params){
    final dynamic jsonDecoded=jsonDecode(params[1]);
    SendPort sendPort=params[0] as SendPort;
    Isolate.exit(sendPort,jsonDecoded);
  }

}