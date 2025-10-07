package com.whatsapp.receive_whatsapp_chat_example

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import com.whatsapp.receive_whatsapp_chat.FlutterShareReceiverActivity

class MainActivity : FlutterShareReceiverActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    companion object {
        private const val CHANNEL = "com.whatsapp.chat/openwhatsapp"
    }

    @SuppressLint("NewApi")
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, _ ->
                if (call.method == "openwhatsapp") {
                    openWhatsApp()
                }
            }
    }

    @SuppressLint("NewApi")
    private fun openWhatsApp() {
        try {
            val launchIntent = packageManager.getLaunchIntentForPackage("com.whatsapp")
            startActivity(launchIntent)
        } catch (e: Exception) {
            Toast.makeText(this, "Error\n${e}", Toast.LENGTH_SHORT).show()
        }
    }
}
