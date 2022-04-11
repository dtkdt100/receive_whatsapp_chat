package com.whatsapp.receive_whatsapp_chat;


import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


/**
 * ReceiveWhatsappChatPlugin
 */
public class ReceiveWhatsappChatPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

    private static final String CHANNEL = "com.whatsapp.chat/chat";
    public static final String TITLE = "title";
    public static final String TEXT = "text";
    public static final String PATH = "path";
    public static final String TYPE = "type";
    public static final String PACKAGE = "package";
    public static final String IS_MULTIPLE = "is_multiple";


    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
