package com.peter.myapplication;

import android.content.Intent;
import android.nfc.Tag;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
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
//import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import io.flutter.embedding.android.FlutterActivityLaunchConfigs;
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

import io.flutter.app.FlutterActivity;
import io.flutter.app.FlutterFragmentActivity;




public class MainActivity extends AppCompatActivity {
//    private static  final String CHANNEL_NATIVE = "com.example.flutter/native";
    private FlutterEngine flutterEngine;
    String message;
    private static  final String CHANNEL = "samples.flutter.io/battery";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        // click button to jump flutter activity
        findViewById(R.id.tv_test).setOnClickListener((view) -> {
            Intent intent = BridgeActivity
                    .withNewEngine()
                    .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.transparent)
                    .build(MainActivity.this);
//            reset class to flutterActivity's sub class, to make my BridgeActivity.configureFlutterEngine effective
            intent.setClass(MainActivity.this, BridgeActivity.class);
            startActivity(intent);
        });

    }


}
