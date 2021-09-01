package com.whatsapp.receive_whatsapp_chat_example;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import io.flutter.plugins.GeneratedPluginRegistrant;

import com.whatsapp.receive_whatsapp_chat.FlutterShareReceiverActivity;

import io.flutter.embedding.engine.FlutterEngine;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterShareReceiverActivity {
    private static final String CHANNEL = "com.whatsapp.chat/openwhatsapp";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this.getFlutterEngine());
    }

    @SuppressLint("NewApi")
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("openwhatsapp")) {
                        openWhatsApp();
                    }
                }
        );
    }

    @SuppressLint("NewApi")
    private void openWhatsApp() {
        try {
            Intent launchIntent = getPackageManager().getLaunchIntentForPackage("com.whatsapp");
            startActivity(launchIntent);
        } catch (Exception e) {
            Toast.makeText(this, "Error\n" + e.toString(), Toast.LENGTH_SHORT).show();
        }
    }
}
