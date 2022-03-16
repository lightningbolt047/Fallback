import 'dart:io';

import 'package:fallback/const.dart';
import 'package:fallback/services/local_backup_service.dart';
import 'package:fallback/services/permissions.dart';
import 'package:fallback/services/secure_storage.dart';
import 'package:fallback/services/shared_prefs.dart';
import 'package:fallback/widgets_basic/buttons/custom_material_button.dart';
import 'package:fallback/widgets_basic/custom_app_bar.dart';
import 'package:fallback/widgets_basic/input_widgets/custom_text_field.dart';
import 'package:fallback/widgets_basic/material_you/custom_alert_dialog.dart';
import 'package:fallback/widgets_basic/page_subheading.dart';
import 'package:fallback/widgets_basic/preference_toggle.dart';
import 'package:fallback/widgets_basic/text_widgets/screen_header_text.dart';
import 'package:fallback/config.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets_basic/material_you/tappable_list_tile.dart';

class SettingsScreen extends StatefulWidget {
  final SecureStorage secureStorage;
  const SettingsScreen({Key? key,required this.secureStorage}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState(secureStorage);
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {

  final SecureStorage secureStorage;

  _SettingsScreenState(this.secureStorage);

  late AnimationController _animationController;
  late Animation<double> _animation;

  late final LocalBackupService _localBackupService;

  String _password="";
  String _confirmPassword="";
  String _oldPassword="";


  @override
  void initState() {

    _localBackupService=LocalBackupService(secureStorage);

    _animationController=AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250)
    );

    _animation=Tween<double>(
      begin: 0,
      end: 1
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CustomScrollView(
            slivers: [
              const CustomSliverAppBar(titleText: "Settings"),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24,),
              ),
              const SliverToBoxAdapter(
                child: PageSubheading(subheadingName: "Encryption & Cloud Sync"),
              ),
              SliverToBoxAdapter(
                child: PreferenceToggle(
                  onChanged: (value) async{
                    await setEnableCloudSyncPreference(value);
                    setState(() {});
                  },
                  getPreference: getEnableCloudSyncPreference,
                  titleText: "Enable Cloud Sync",
                  subtitleText: "Cloud sync enables you to backup your keys safely to the cloud and lets you access the keys across devices",
                ),
              ),
              SliverToBoxAdapter(
                child: TappableListTile(
                  titleText: "Set Encryption Password",
                  subtitleText: "This password is used to encrypt your keys before syncing to the cloud or exporting a backup",
                  leading: const Icon(Icons.key,color: kIconColor,),
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (context)=>FutureBuilder(
                        future: secureStorage.readEncryptionPassword(),
                        builder: (BuildContext context,AsyncSnapshot<String?> snapshot) {

                          if(!snapshot.hasData  && snapshot.connectionState==ConnectionState.waiting){
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: kBackgroundColor,));
                          }

                          return CustomAlertDialog(
                            title: Text("Set Password",style: GoogleFonts.quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),),
                            backgroundColor: kBackgroundColor,
                            content: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: const [
                                    Icon(Icons.warning_rounded,color: Colors.red,),
                                    Text("Password cannot be recovered if lost",maxLines: 5,),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                if(snapshot.data!=null)...[
                                  CustomTextField(
                                    onChanged: (value){
                                      _oldPassword=value;
                                    },
                                    obscureText: true,
                                    filled: true,
                                    labelText: "Old Password",
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                ],
                                CustomTextField(
                                  onChanged: (value){
                                    _password=value;
                                  },
                                  obscureText: true,
                                  filled: true,
                                  labelText: "New Password",
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                CustomTextField(
                                  onChanged: (value){
                                    _confirmPassword=value;
                                  },
                                  obscureText: true,
                                  filled: true,
                                  labelText: "Confirm Password",
                                ),
                              ],
                            ),
                            actions: [
                              OutlinedButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel",style: TextStyle(color: kIconColor),),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  side: const BorderSide(color: kIconColor),
                                  primary: kIconColor,
                                ),
                              ),
                              CustomMaterialButton(
                                child: const Text("OK",style: TextStyle(
                                    color: kBackgroundColor
                                ),),
                                onPressed: () async{
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  if(snapshot.data!=null && snapshot.data!=_oldPassword){
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect old password! Password not changed")));
                                    return;
                                  }
                                  if(_password!=_confirmPassword){
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match! Password not changed")));
                                    return;
                                  }
                                  if(_password.length<8){
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password must be at least 8 characters long! Password not changed")));
                                    return;
                                  }
                                  try{
                                    await secureStorage.writeEncryptionPassword(_password);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password change successful")));
                                    Navigator.pop(context);
                                  }catch(e){
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to change password")));
                                  }

                                },
                                buttonColor: kIconColor,
                              ),
                            ],
                          );
                        }
                      ),
                    );
                  },
                ),
              ),
              if(enableLocalBackups)...[
                const SliverToBoxAdapter(
                  child: PageSubheading(subheadingName: "Backup and Restore"),
                ),
                SliverToBoxAdapter(
                  child: TappableListTile(
                    titleText: "Export Backup",
                    subtitleText: "Keys are encrypted using your password and saved on your local storage",
                    leading: const Icon(Icons.backup_table_rounded, color: kIconColor,),
                    onTap: (){
                      showDialog(
                          context: context,
                          builder: (context)=>FutureBuilder(
                            future: secureStorage.readEncryptionPassword(),
                            builder: (BuildContext context, AsyncSnapshot<String?> snapshot){
                              if(!snapshot.hasData && snapshot.connectionState==ConnectionState.waiting){
                                return const Center(child: CircularProgressIndicator(strokeWidth: 2,color: kBackgroundColor,),);
                              }
                              if(snapshot.data==null){
                                return CustomAlertDialog(
                                  title: const Text("Encryption password not set",style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),),
                                  backgroundColor: kBackgroundColor,
                                  content: const Text("The password is used to encrypt the data before exporting it as a backup. Please set a password before proceeding"),
                                  actions: [
                                    CustomMaterialButton(
                                      child: const Text("OK",style: TextStyle(
                                          color: kBackgroundColor
                                      ),),
                                      buttonColor: kIconColor,
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              }
                              return FutureBuilder(
                                  future: Permissions.getStoragePermissions(),
                                  builder: (BuildContext context,AsyncSnapshot<bool> snapshot) {

                                    if(!snapshot.hasData){
                                      return const Center(child: CircularProgressIndicator(strokeWidth: 2,color: kBackgroundColor,),);
                                    }
                                    if(!snapshot.data!){
                                      return CustomAlertDialog(
                                        title: const Text("Failed to export backup",style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),),
                                        backgroundColor: kBackgroundColor,
                                        content: const Text("Required permissions were not granted"),
                                        actions: [
                                          CustomMaterialButton(
                                            child: const Text("OK",style: TextStyle(
                                              color: kBackgroundColor,
                                            ),),
                                            buttonColor: kIconColor,
                                            onPressed: (){
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    }


                                    return FutureBuilder(
                                      future: FilePicker.platform.getDirectoryPath(dialogTitle: "Choose where to save backup"),
                                      builder: (BuildContext context,AsyncSnapshot<String?> snapshot){
                                        if(!snapshot.hasData && snapshot.connectionState==ConnectionState.waiting){
                                          return const Center(child: CircularProgressIndicator(strokeWidth: 2,color: kBackgroundColor,),);
                                        }
                                        if(snapshot.data==null){
                                          return CustomAlertDialog(
                                            title: const Text("Failed to export backup",style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),),
                                            backgroundColor: kBackgroundColor,
                                            content: const Text("Directory to save was not selected"),
                                            actions: [
                                              CustomMaterialButton(
                                                child: const Text("OK",style: TextStyle(
                                                  color: kBackgroundColor,
                                                ),),
                                                buttonColor: kIconColor,
                                                onPressed: (){
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        }
                                        return FutureBuilder(
                                          future: _localBackupService.backupAllKeys(snapshot.data!),
                                          builder: (BuildContext context,AsyncSnapshot<void> backupStatusSnapshot){
                                            if(!backupStatusSnapshot.hasData && backupStatusSnapshot.connectionState==ConnectionState.waiting){
                                              return CustomAlertDialog(
                                                title: const Text("Encrypting and Exporting backup",style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),),
                                                backgroundColor: kBackgroundColor,
                                                content: Row(
                                                  children: const [
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: kIconColor,
                                                    ),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text("Exporting Backup")
                                                  ],
                                                ),
                                              );
                                            }
                                            if(backupStatusSnapshot.hasError){
                                              return CustomAlertDialog(
                                                title: const Text("Failed to export backup",style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),),
                                                backgroundColor: kBackgroundColor,
                                                content: const Text("Something went wrong while exporting the backup"),
                                                actions: [
                                                  CustomMaterialButton(
                                                    child: const Text("OK",style: TextStyle(
                                                      color: kBackgroundColor,
                                                    ),),
                                                    buttonColor: kIconColor,
                                                    onPressed: (){
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              );
                                            }
                                            return CustomAlertDialog(
                                              title: const Text("Backup exported successfully",style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),),
                                              backgroundColor: kBackgroundColor,
                                              content: Text("Backup is stored in: ${snapshot.data!}"),
                                              actions: [
                                                CustomMaterialButton(
                                                  child: const Text("OK",style: TextStyle(
                                                    color: kBackgroundColor,
                                                  ),),
                                                  buttonColor: kIconColor,
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                              );
                            },
                          )
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: TappableListTile(
                    titleText: "Restore Backup",
                    subtitleText: "Import encrypted backups using the password used to encrypt the backup",
                    leading: const Icon(Icons.restore_rounded, color: kIconColor,),
                    onTap: (){},
                  ),
                ),
              ],
            ],
          )
      ),
    );
  }
}
