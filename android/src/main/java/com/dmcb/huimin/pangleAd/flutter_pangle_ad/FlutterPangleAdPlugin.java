package com.dmcb.huimin.pangleAd.flutter_pangle_ad;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.NonNull;

import com.bytedance.sdk.openadsdk.TTAdConfig;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdSdk;
import com.dmcb.huimin.pangleAd.flutter_pangle_ad.ad.RewardVideoAd;
import com.dmcb.huimin.pangleAd.flutter_pangle_ad.ad.SplashAd;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

/**
 * FlutterPangleAdPlugin
 */
public class FlutterPangleAdPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private MethodChannel channel;

    private Context mAppContext;

    private FlutterPluginBinding mBinding;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_pangle_ad");
        channel.setMethodCallHandler(this);
        mAppContext = flutterPluginBinding.getApplicationContext();
        mBinding = flutterPluginBinding;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("initialSDK")) {
            initialSDK(call, result);
        } else if (call.method.equals("showSplashAd")) {
            showSplashAd(call, result);
        } else if (call.method.equals("loadSplashAd")) {
            loadSplashAd(call, result);
        } else if (call.method.equals("showRewardAd")) {
            showRewardAd(call, result);
        } else if (call.method.equals("loadRewardAd")) {
            loadRewardAd(call, result);
        } else {
            result.notImplemented();
        }
    }

    /**
     * ??????????????????
     *
     * @param call
     * @param result
     */
    public void initialSDK(MethodCall call, final Result result) {
        TTAdSdk.init(mAppContext,
                new TTAdConfig.Builder()
                        .appId(call.argument("appId") + "")
                        .useTextureView(true) //??????TextureView??????????????????,?????????SurfaceView,??????SurfaceView??????????????????????????????TextureView
                        .appName("????????????")
                        .titleBarTheme(TTAdConstant.TITLE_BAR_THEME_DARK)
                        .allowShowNotify(true) //????????????sdk?????????????????????
                        .directDownloadNetworkType() //???????????????????????????????????????
                        .build(), new TTAdSdk.InitCallback() {
                    @Override
                    public void success() {
                        Log.d("TTAdSdk", "???????????????~");
                    }

                    @Override
                    public void fail(int i, String s) {
                    }
                });
        Log.d("TTAdSdk", TTAdSdk.getAdManager().getSDKVersion());
    }

    /**
     * ???????????????????????????
     *
     * @param call
     * @param result
     */
    public void showSplashAd(MethodCall call, Result result) {
        SplashAd.setCallBack(result, call.argument("slotID") + "");
        Intent intent = new Intent(mAppContext, SplashAd.class);
        intent.setFlags(FLAG_ACTIVITY_NEW_TASK);
        mAppContext.startActivity(intent);
    }

    /**
     * ????????????????????????
     *
     * @param call
     * @param result
     */
    public void showRewardAd(MethodCall call, Result result) {
        RewardVideoAd.setCallBack(result, call.argument("slotID") + "");
        Intent intent = new Intent(mAppContext, RewardVideoAd.class);
        intent.setFlags(FLAG_ACTIVITY_NEW_TASK);
        mAppContext.startActivity(intent);
    }

    /**
     * ?????????????????????
     *
     * @param call
     * @param result
     */
    public void loadSplashAd(MethodCall call, Result result) {
    }

    /**
     * ???????????????????????????
     *
     * @param call
     * @param result
     */
    public void loadRewardAd(MethodCall call, Result result) {
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        // ????????????
        mBinding.getPlatformViewRegistry().registerViewFactory("PangleAdBannerView", new NativeViewFactory(binding.getActivity()));
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}
