import 'package:shared_preferences/shared_preferences.dart';

Future<void> setEnableCloudSyncPreference(bool value) async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  pref.setBool("cloudSync", value);
}

Future<bool?> getEnableCloudSyncPreference() async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  if(pref.getBool("cloudSync")==null){
    pref.setBool("cloudSync", false);
    return false;
  }
  return pref.getBool("cloudSync");
}