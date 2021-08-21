package com.dmcb.huimin.pangleAd.flutter_pangle_ad.ad;

import android.app.Activity;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.widget.Toast;

import androidx.annotation.MainThread;
import androidx.annotation.Nullable;

import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdManager;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAdSdk;
import com.bytedance.sdk.openadsdk.TTAppDownloadListener;
import com.bytedance.sdk.openadsdk.TTRewardVideoAd;

import io.flutter.plugin.common.MethodChannel;

public class RewardVideoAd extends Activity {

    private TTAdNative mTTAdNative;
    private TTRewardVideoAd mttRewardVideoAd;

    private boolean mHasShowDownloadActive = false;

    private static MethodChannel.Result mCallBack;
    private static String mAdId;

    public static void setCallBack(MethodChannel.Result _callBack, String adId) {
        mCallBack = _callBack;
        mAdId = adId;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //step1:初始化sdk
        TTAdManager ttAdManager = TTAdSdk.getAdManager();
        //step2:(可选，强烈建议在合适的时机调用):申请部分权限，如read_phone_state,防止获取不了imei时候，下载类广告没有填充的问题。
        TTAdSdk.getAdManager().requestPermissionIfNecessary(this);
        //step3:创建TTAdNative对象,用于调用广告请求接口
        mTTAdNative = ttAdManager.createAdNative(getApplicationContext());
        loadAd();
    }

    private void loadAd() {
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);

        float screenWidth = dm.widthPixels / dm.density;
        float screenHeight = dm.heightPixels / dm.density;

        AdSlot adSlot = new AdSlot.Builder().setCodeId(mAdId).setExpressViewAcceptedSize(screenWidth, screenHeight * 0.85f).build();
        //step5:请求广告
        mTTAdNative.loadRewardVideoAd(adSlot, new TTAdNative.RewardVideoAdListener() {
            @Override
            public void onError(int code, String message) {
                showToast("onError " + code + ", " + message);
            }

            //视频广告加载后，视频资源缓存到本地的回调，在此回调后，播放本地视频，流畅不阻塞。
            @Override
            public void onRewardVideoCached() {
                showToast("onRewardVideoCached");
                if (mttRewardVideoAd != null) {
                    //step6:在获取到广告后展示,强烈建议在onRewardVideoCached回调后，展示广告，提升播放体验
                    //展示广告，并传入广告展示的场景
                    mttRewardVideoAd.showRewardVideoAd(RewardVideoAd.this, TTAdConstant.RitScenes.CUSTOMIZE_SCENES, "获取提货卡3980");
                    mttRewardVideoAd = null;
                }
            }

            //视频广告的素材加载完毕，比如视频url等，在此回调后，可以播放在线视频，网络不好可能出现加载缓冲，影响体验。
            @Override
            public void onRewardVideoAdLoad(TTRewardVideoAd ad) {
                showToast("广告类型：" + getAdType(ad.getRewardVideoAdType()));
                mttRewardVideoAd = ad;
                ad.setRewardAdInteractionListener(new TTRewardVideoAd.RewardAdInteractionListener() {

                    @Override
                    public void onAdShow() {
                        showToast("onAdShow");
                    }

                    @Override
                    public void onAdVideoBarClick() {
                        showToast("onAdVideoBarClick");
                    }

                    @Override
                    public void onAdClose() {
                        showToast("onAdClose");
                    }

                    //视频播放完成回调
                    @Override
                    @MainThread
                    public void onVideoComplete() {
                        showToast("onVideoComplete");
                        if (mCallBack != null) {
                            mCallBack.success(null);
                            mCallBack = null;
                        }
                        finish();
                    }

                    @Override
                    public void onVideoError() {
                        showToast("onVideoError");
                    }

                    //视频播放完成后，奖励验证回调，rewardVerify：是否有效，rewardAmount：奖励梳理，rewardName：奖励名称
                    @Override
                    public void onRewardVerify(boolean rewardVerify, int rewardAmount, String rewardName, int errorCode, String errorMsg) {
                        String logString = "verify:" + rewardVerify + " amount:" + rewardAmount +
                                " name:" + rewardName + " errorCode:" + errorCode + " errorMsg:" + errorMsg;
                        showToast(logString);
                        finish();
                    }

                    @Override
                    public void onSkippedVideo() {
                        showToast("onSkippedVideo");
                    }
                });
                if (ad.getInteractionType() == TTAdConstant.INTERACTION_TYPE_DOWNLOAD) {
                    ad.setDownloadListener(new TTAppDownloadListener() {
                        @Override
                        public void onIdle() {
                            mHasShowDownloadActive = false;
                        }

                        @Override
                        public void onDownloadActive(long totalBytes, long currBytes, String fileName, String appName) {
                            if (!mHasShowDownloadActive) {
                                mHasShowDownloadActive = true;
                                showToast("下载中，点击下载区域暂停");
                            }
                        }

                        @Override
                        public void onDownloadPaused(long totalBytes, long currBytes, String fileName, String appName) {
                            showToast("下载暂停，点击下载区域继续");
                        }

                        @Override
                        public void onDownloadFailed(long totalBytes, long currBytes, String fileName, String appName) {
                            showToast("下载失败，点击下载区域重新下载");
                        }

                        @Override
                        public void onDownloadFinished(long totalBytes, String fileName, String appName) {
                            showToast("下载完成，点击下载区域重新下载");
                        }

                        @Override
                        public void onInstalled(String fileName, String appName) {
                            showToast("安装完成，点击下载区域打开");
                        }
                    });
                }
            }
        });
    }

    private String getAdType(int type) {
        switch (type) {
            case TTAdConstant.AD_TYPE_COMMON_VIDEO:
                return "普通激励视频，type=" + type;
            case TTAdConstant.AD_TYPE_PLAYABLE_VIDEO:
                return "Playable激励视频，type=" + type;
            case TTAdConstant.AD_TYPE_PLAYABLE:
                return "纯Playable，type=" + type;
        }
        return "未知类型+type=" + type;
    }

    private void showToast(String msg) {
//        Toast.makeText(this, msg, Toast.LENGTH_LONG).show();
    }
}
