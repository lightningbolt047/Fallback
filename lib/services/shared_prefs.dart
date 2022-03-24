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

Future<void> setSetupCompletedPreference(bool value) async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  pref.setBool("setupComplete", value);
}

Future<bool?> getSetupCompletedPreference() async{
  SharedPreferences pref=await SharedPreferences.getInstance();
  if(pref.getBool("setupComplete")==null){
    pref.setBool("setupComplete", false);
    return false;
  }
  return pref.getBool("setupComplete");
}