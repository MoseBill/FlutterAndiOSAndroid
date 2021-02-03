package com.peter.myapplication;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Intent;
import android.nfc.Tag;
import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

//import io.flutter.embedding.android.FlutterActivityLaunchConfigs;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.StringCodec;

//import io.flutter.app.FlutterActivity;
import io.flutter.app.FlutterFragmentActivity;

/**flu
 * @author peter
 */
public class BridgeActivity extends FlutterActivity {
    private static final String CHANNEL_NAME = "flutter.bridge.call_platform";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        getFlutterEngine();
        //config a method channel
//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME)
//                .setMethodCallHandler((call, result) -> {
//                    switch (call.method) {
//                        case "testMethod":
//                            result.success("This is respond result from Android native method");
//                            break;
//                        default:
//                            result.notImplemented();
//                            break;
//                    }
//                });
//        MethodChannel nativeChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),CHANNEL_NAME);
//        nativeChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
//            @Override
//            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
//                switch (call.method) {
//                    case "jumpToNative"://跳转原生页面
//                        if (call.arguments != null) {
////                            Toast.makeText(call.argument("message"),call.arguments("messageToniubi"),12);
//
//                            Toast.makeText(BridgeActivity.this, "message", Toast.LENGTH_SHORT).show();
//                        } else  {
//                            Toast.makeText(BridgeActivity.this, "回调参数为空", Toast.LENGTH_SHORT).show();
//                        }
////                        startActivity(intent);
//                        result.success("Activity -> Flutter 接收回调的返回值成功");
//                        break;
//                    default:
//                        result.notImplemented();
//                        break;
//                }
//            }
//        });
    }

    public static FlutterActivity.NewEngineIntentBuilder withNewEngine() {
        return new MyNewEngineIntentBuilder(BridgeActivity.class);
    }

    public static FlutterActivity.CachedEngineIntentBuilder withCachedEngine(@NonNull String cachedEngineId) {
        return new MyCachedEngineIntentBuilder(BridgeActivity.class, cachedEngineId);
    }

    /**
     * 之所以"空"继承{@link io.flutter.embedding.android.FlutterActivity.NewEngineIntentBuilder}，因为内建在Intent创建时静态的写定了
     * FlutterActivity.class，从而导致在此继承的子类中重写的configureFlutterEngine(FlutterEngine)不生效。
     * 且用到的NewEngineIntentBuilder的构造器包外不可访问，因此无法重写相关方法而继续保持按内建方式获取Intent。继承一下将构造器外用
     */
    public static class MyNewEngineIntentBuilder extends NewEngineIntentBuilder {

        MyNewEngineIntentBuilder(@NonNull Class<? extends FlutterActivity> activityClass) {
            super(activityClass);
        }
    }

    public static class MyCachedEngineIntentBuilder extends CachedEngineIntentBuilder{

        protected MyCachedEngineIntentBuilder(@NonNull Class<? extends FlutterActivity> activityClass, @NonNull String engineId) {
            super(activityClass, engineId);
        }
    }
}
