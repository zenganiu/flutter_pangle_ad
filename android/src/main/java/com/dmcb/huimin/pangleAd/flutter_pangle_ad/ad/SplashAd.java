package com.dmcb.huimin.pangleAd.flutter_pangle_ad.ad;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.MainThread;

import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAdSdk;
import com.bytedance.sdk.openadsdk.TTAppDownloadListener;
import com.bytedance.sdk.openadsdk.TTSplashAd;
import com.dmcb.huimin.pangleAd.flutter_pangle_ad.R;

import java.util.Timer;
import java.util.TimerTask;

public class SplashAd extends Activity {

    private TTAdNative mTTAdNative;
    private FrameLayout mSplashContainer;

    //开屏广告加载超时时间,建议大于3000,这里为了冷启动第一次加载到广告并且展示,示例设置了3000ms
    private static int AD_TIME_OUT = 5000;

    @SuppressWarnings("RedundantCast")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash_x);
        mSplashContainer = (FrameLayout) findViewById(R.id.splash_container);
        mTTAdNative = TTAdSdk.getAdManager().createAdNative(this);
//        AD_TIME_OUT = Integer.parseInt(getIntent().getStringExtra("tolerateTimeout"));
        loadSplashAd();
    }

    /**
     * 加载开屏广告
     */
    private void loadSplashAd() {
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);

        final int expressViewWidth = (int) (dm.widthPixels / dm.density);
        int screenHeight = (int) (dm.heightPixels / dm.density);

        final float _expressViewHeight = screenHeight * 0.15f;
        final float expressViewHeight = screenHeight * 0.85f;

        AdSlot adSlot = new AdSlot.Builder()
                .setCodeId(getIntent().getStringExtra("slotID"))
                .setExpressViewAcceptedSize(expressViewWidth, expressViewHeight)
                .build();

        //step4:请求广告，调用开屏广告异步请求接口，对请求回调的广告作渲染处理
        mTTAdNative.loadSplashAd(adSlot, new TTAdNative.SplashAdListener() {
            @Override
            @MainThread
            public void onError(int code, String message) {
                showToast(message);
                goToMainActivity();
            }

            @Override
            @MainThread
            public void onTimeout() {
                showToast("开屏广告加载超时");
                goToMainActivity();
            }

            @Override
            @MainThread
            public void onSplashAdLoad(TTSplashAd ad) {
                showToast("开屏广告请求成功");
                if (ad == null) {
                    return;
                }
                ad.setNotAllowSdkCountdown();
                mListener = new TTSplashAd.AdInteractionListener() {
                    @Override
                    public void onAdClicked(View view, int type) {
                        showToast("开屏广告点击");
                    }

                    @Override
                    public void onAdShow(View view, int type) {
                        showToast("开屏广告展示");
                    }

                    @Override
                    public void onAdSkip() {
                        showToast("开屏广告跳过");
                    }

                    @Override
                    public void onAdTimeOver() {
                        showToast("开屏广告倒计时结束");
                        goToMainActivity();
                    }
                };
                //获取SplashView
                View view = ad.getSplashView();
                if (mSplashContainer != null && !SplashAd.this.isFinishing()) {
                    mSplashContainer.removeAllViews();
                    //把SplashView 添加到ViewGroup中,注意开屏广告view：width >=70%屏幕宽；height >=50%屏幕高
                    mSplashContainer.addView(view, new FrameLayout.LayoutParams(expressViewWidth, (int) expressViewHeight));
                    ImageView imageView = new ImageView(getBaseContext());
                    imageView.setImageResource(R.drawable.tt_ad_logo_small);
                    imageView.setScaleType(ImageView.ScaleType.CENTER);
                    imageView.setBackgroundResource(R.color.color_333);
                    mSplashContainer.addView(imageView, new FrameLayout.LayoutParams(expressViewWidth, (int) _expressViewHeight, Gravity.BOTTOM));
                    mClose = new TextView(getBaseContext());
                    mClose.setBackgroundColor(getBaseContext().getResources().getColor(R.color.color_333));
                    mClose.setTextColor(getBaseContext().getResources().getColor(R.color.white));
                    mClose.setText("跳过");
                    mClose.getBackground().setAlpha(150);
                    mClose.setGravity(Gravity.CENTER);
                    mClose.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            goToMainActivity();
                        }
                    });
                    int wrap = FrameLayout.LayoutParams.WRAP_CONTENT;
                    @SuppressLint("RtlHardcoded") FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(180, wrap, Gravity.TOP | Gravity.RIGHT);
                    mClose.setPadding(0, 15, 0, 15);
                    layoutParams.topMargin = 50;
                    layoutParams.rightMargin = 50;
                    mSplashContainer.addView(mClose, layoutParams);
                    countDown();
                }
                //设置SplashView的交互监听器
                ad.setSplashInteractionListener(mListener);
                if (ad.getInteractionType() == TTAdConstant.INTERACTION_TYPE_DOWNLOAD) {
                    ad.setDownloadListener(new TTAppDownloadListener() {
                        boolean hasShow = false;

                        @Override
                        public void onIdle() {
                        }

                        @Override
                        public void onDownloadActive(long totalBytes, long currBytes, String fileName, String appName) {
                            if (!hasShow) {
                                showToast("下载中...");
                                hasShow = true;
                            }
                        }

                        @Override
                        public void onDownloadPaused(long totalBytes, long currBytes, String fileName, String appName) {
                            showToast("下载暂停...");
                        }

                        @Override
                        public void onDownloadFailed(long totalBytes, long currBytes, String fileName, String appName) {
                            showToast("下载失败...");
                        }

                        @Override
                        public void onDownloadFinished(long totalBytes, String fileName, String appName) {
                            showToast("下载完成...");
                        }

                        @Override
                        public void onInstalled(String fileName, String appName) {
                            showToast("安装完成...");
                        }
                    });
                }
            }
        }, AD_TIME_OUT);
    }

    @Override
    protected void onDestroy() {
        if (mTask != null) {
            mTask.cancel();
            mTimer = null;
        }
        super.onDestroy();
    }

    /**
     * 倒计时显示
     */
    TTSplashAd.AdInteractionListener mListener;
    private Timer mTimer = new Timer();
    private TimerTask mTask;
    private TextView mClose;
    private int mTime = 6;

    private void countDown() {
        mTask = new TimerTask() {
            @SuppressLint("SetTextI18n")
            @Override
            public void run() {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mTime--;
                        mClose.setText(mTime + " 跳过");
                        if (mTime <= 0) {
                            mClose.setText("跳过");
                            goToMainActivity();
                        }
                    }
                });
            }
        };
        //调用方法
        mTimer.schedule(mTask, mTime, 1000);
    }

    /**
     * 跳转到主页面
     */
    private synchronized void goToMainActivity() {
        if (mTask != null) {
            mTask.cancel();
            mTimer = null;
        }
        mSplashContainer.removeAllViews();
        finish();
    }

    private void showToast(String msg) {
        Toast.makeText(this, msg, Toast.LENGTH_LONG).show();
    }
}
