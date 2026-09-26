package com.whatsapp.receive_whatsapp_chat;


import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


/**
 * ReceiveWhatsappChatPlugin
 */
public class ReceiveWhatsappChatPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

    private static final String CHANNEL = "com.whatsapp.chat/chat";
    private static final String TAG = "receive_whatsapp_chat";
    public static final String TITLE = "title";
    public static final String TEXT = "text";
    public static final String PATH = "path";
    public static final String TYPE = "type";
    public static final String PACKAGE = "package";
    public static final String IS_MULTIPLE = "is_multiple";


    private MethodChannel channel;
    private Context context;
    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if ("contentUriToFile".equals(call.method)) {
            final String uri = call.argument("uri");
            executor.execute(() -> {
                try {
                    final String path = copyContentUriToCache(Uri.parse(uri));
                    mainHandler.post(() -> result.success(path));
                } catch (Exception e) {
                    Log.e(TAG, "Failed to copy shared uri (authority: "
                            + (uri == null ? null : Uri.parse(uri).getAuthority()) + ") to a file", e);
                    mainHandler.post(() -> result.error("URI_TO_FILE", e.getMessage(), null));
                }
            });
        } else {
            result.notImplemented();
        }
    }

    /**
     * Copies the content behind a content:// uri (the exported chat zip) into the cache dir.
     */
    private String copyContentUriToCache(Uri uri) throws IOException {
        File file = new File(context.getCacheDir(), "whatsapp_chat_export.zip");
        try (InputStream in = context.getContentResolver().openInputStream(uri);
             OutputStream out = new FileOutputStream(file)) {
            if (in == null) throw new IOException("Cannot open " + uri);
            byte[] buffer = new byte[8192];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
        }
        return file.getAbsolutePath();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
