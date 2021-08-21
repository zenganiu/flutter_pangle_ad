package com.dmcb.huimin.pangleAd.flutter_pangle_ad.ad;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdDislike;
import com.bytedance.sdk.openadsdk.TTAdManager;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAdSdk;
import com.bytedance.sdk.openadsdk.TTAppDownloadListener;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;
import com.dmcb.huimin.pangleAd.flutter_pangle_ad.R;

import java.util.List;
import java.util.Map;

import io.flutter.plugin.platform.PlatformView;

public class BannerAd implements PlatformView {

    private Context mContext;
    private Activity mActivity;

    private TTNativeExpressAd mTTAd;
    private TTAdNative mTTAdNative;
    private FrameLayout mExpressContainer;

    private View mView;

    public BannerAd(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams, Activity activity) {
        mActivity = activity;
        mContext = context;
        TTAdManager ttAdManager = TTAdSdk.getAdManager();
        mTTAdNative = ttAdManager.createAdNative(mContext);
        mView = View.inflate(mContext, R.layout.activity_banner_x, null);
        mExpressContainer = mView.findViewById(R.id.banner_ad);
        loadExpressAd(creationParams.get("slotID") + "",
                Double.valueOf(creationParams.get("viewWidth") + "").intValue(),
                Double.valueOf(creationParams.get("viewHeight") + "").intValue());
    }

    private void loadExpressAd(String id, int width, int height) {
        mExpressContainer.removeAllViews();
        AdSlot adSlot = new AdSlot.Builder()
                .setCodeId(id)
                .setAdCount(1)
                .setExpressViewAcceptedSize(width, height)
                .build();
        //step5:请求广告，对请求回调的广告作渲染处理
        mTTAdNative.loadBannerExpressAd(adSlot, new TTAdNative.NativeExpressAdListener() {
            @Override
            public void onError(int code, String message) {
                mExpressContainer.removeAllViews();
            }

            @Override
            public void onNativeExpressAdLoad(List<TTNativeExpressAd> ads) {
                if (ads == null || ads.size() == 0) {
                    return;
                }
                mTTAd = ads.get(0);
                mTTAd.setSlideIntervalTime(30 * 1000);
                bindAdListener(mTTAd);
                mTTAd.render();
            }
        });
    }

    private void bindAdListener(final TTNativeExpressAd ad) {
        ad.setExpressInteractionListener(new TTNativeExpressAd.ExpressAdInteractionListener() {
            @Override
            public void onAdClicked(View view, int type) {
            }

            @Override
            public void onAdShow(View view, int type) {
            }

            @Override
            public void onRenderFail(View view, String msg, int code) {
                Log.d("substring", msg + " code:" + code);
            }

            @Override
            public void onRenderSuccess(View view, float width, float height) {
                mExpressContainer.removeAllViews();
                mExpressContainer.addView(ad.getExpressAdView());
            }
        });
        //dislike设置
        bindDislike(ad);
        if (ad.getInteractionType() != TTAdConstant.INTERACTION_TYPE_DOWNLOAD) {
            return;
        }
        ad.setDownloadListener(new TTAppDownloadListener() {
            @Override
            public void onIdle() {
            }

            @Override
            public void onDownloadActive(long totalBytes, long currBytes, String fileName, String appName) {
            }

            @Override
            public void onDownloadPaused(long totalBytes, long currBytes, String fileName, String appName) {
            }

            @Override
            public void onDownloadFailed(long totalBytes, long currBytes, String fileName, String appName) {
            }

            @Override
            public void onInstalled(String fileName, String appName) {
            }

            @Override
            public void onDownloadFinished(long totalBytes, String fileName, String appName) {
            }
        });
        ad.render();
    }

    /**
     * 设置广告的不喜欢, 注意：强烈建议设置该逻辑，如果不设置dislike处理逻辑，则模板广告中的 dislike区域不响应dislike事件。
     *
     * @param ad
     */
    private void bindDislike(TTNativeExpressAd ad) {
        ad.setDislikeCallback(mActivity, new TTAdDislike.DislikeInteractionCallback() {
            @Override
            public void onShow() {

            }

            @Override
            public void onSelected(int position, String value) {
                mExpressContainer.removeAllViews();
            }

            @Override
            public void onCancel() {
            }

            @Override
            public void onRefuse() {

            }
        });
    }

    @Override
    public View getView() {
        return mView;
    }

    @Override
    public void dispose() {
        mExpressContainer.removeAllViews();
    }
}
