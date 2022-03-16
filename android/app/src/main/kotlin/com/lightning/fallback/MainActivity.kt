package com.lightning.fallback

import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileWriter

class MainActivity: FlutterFragmentActivity() {
    private val channelName="com.lightning.fallback"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,channelName).setMethodCallHandler {
            call, result ->
                if(call.method=="saveBackupToDownloads"){
                    try{
                        saveBackupToDownloads(call.arguments(),result)
//                        result.success("0")
                    }catch (e: Exception){
//                        result.error("1","Failed","Failed to write file")
                    }
                }else{
                    result.notImplemented();
                }

        }
    }

    private fun saveBackupToDownloads(path: String?,result: MethodChannel.Result) {
        val path=Environment.DIRECTORY_DOWNLOADS
        MediaStore.Downloads.
        val file: FileWriter = FileWriter(path)
    }



}
