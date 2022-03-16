import 'package:permission_handler/permission_handler.dart';

class Permissions{

  static Future<bool> getStoragePermissions() async{
    PermissionStatus storagePermission=await Permission.storage.status;
    if(storagePermission!=PermissionStatus.granted){
      storagePermission=await Permission.storage.request();
    }
    return storagePermission==PermissionStatus.granted;
  }
}