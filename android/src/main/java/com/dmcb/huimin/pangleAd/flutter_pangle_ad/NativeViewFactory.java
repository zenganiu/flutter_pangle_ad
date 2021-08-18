package com.dmcb.huimin.pangleAd.flutter_pangle_ad;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.dmcb.huimin.pangleAd.flutter_pangle_ad.ad.BannerAd;

import java.util.Map;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

class NativeViewFactory extends PlatformViewFactory {

    NativeViewFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    @NonNull
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new BannerAd(context, id, creationParams);
    }
}
