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
//    if (call.method.equals("share")) {
//      if (!(call.arguments instanceof Map)) {
//        throw new IllegalArgumentException("Map argument expected");
//      }
//      // Android does not support showing the share sheet at a particular point on screen.
//      String packageName=call.hasArgument(PACKAGE) ? (String) call.argument(PACKAGE) : "";
//      if (call.argument(IS_MULTIPLE)) {
//        ArrayList<Uri> dataList = new ArrayList<>();
//        for (int i = 0; call.hasArgument(Integer.toString(i)); i++) {
//          dataList.add(Uri.parse((String)call.argument(Integer.toString(i))));
//        }
//        shareMultiple(dataList, (String) call.argument(TYPE), call.hasArgument(TITLE) ? (String) call.argument(TITLE) : "",packageName);
//      } else {
//        ReceiveWhatsappChatPlugin.ShareType shareType = ReceiveWhatsappChatPlugin.ShareType.fromMimeType((String) call.argument(TYPE));
//        if (ReceiveWhatsappChatPlugin.ShareType.TYPE_PLAIN_TEXT.equals(shareType)) {
//          share((String) call.argument(TEXT), shareType, call.hasArgument(TITLE) ? (String) call.argument(TITLE) : "",packageName);
//        } else {
//          share((String) call.argument(PATH), (call.hasArgument(TEXT) ? (String) call.argument(TEXT) : ""), shareType, (call.hasArgument(TITLE) ? (String) call.argument(TITLE) : ""),packageName);
//        }
//      }
//      result.success(null);
//    } else if (call.method.equals("analyze")) {
//      System.out.println("Yoo we got here!");
//      String URL = call.argument("data");
//      Uri students = Uri.parse(URL);
//      //Cursor c = getContentResolver().query(students, null, null, null, null);
//
//    } else {
//      result.notImplemented();
//    }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
