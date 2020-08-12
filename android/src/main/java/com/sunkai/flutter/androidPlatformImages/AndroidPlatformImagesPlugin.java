package com.sunkai.flutter.androidPlatformImages;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AndroidPlatformImagesPlugin */
public class AndroidPlatformImagesPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static final String TAG = "AndroidPlatformImages";
  private Context mContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    mContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.sunkai/android_platform_images");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
//    mContext = registrar.context();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "android_platform_images");
    channel.setMethodCallHandler(new AndroidPlatformImagesPlugin());
  }

  @SuppressLint("WrongThread")
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("loadImage")) {
      try {
        Log.d(TAG, "configureFlutterEngine: " + call.toString());
        Log.d(TAG, "configureFlutterEngine: " + call.arguments.toString());
        String name = (String)call.arguments;
        int drawableId = mContext.getResources()
                .getIdentifier(name, "drawable", mContext.getPackageName());
        Bitmap bitmap = BitmapFactory.decodeResource(mContext.getResources(), drawableId);
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        if (bitmap == null) {
          result.success(null);
          return;
        }
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, bos);
        byte[] bytes = bos.toByteArray();
        result.success(bytes);
      } catch (Exception e) {
        Log.e(TAG, "configureFlutterEngine: ", e);
        result.success(null);
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
