package com.clothe.skin.roblox.emotes.shirt.rbxconverter.calculator.ai

import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

class NativeAdFactoryMedium(private val layoutInflater: LayoutInflater) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.ad_unit_admob_med, null) as NativeAdView

        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val ctaView = adView.findViewById<TextView>(R.id.ad_call_to_action)
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)

        // Headline
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        // Body
        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        adView.bodyView = bodyView

        // Call To Action
        if (nativeAd.callToAction != null) {
            ctaView.text = nativeAd.callToAction
            ctaView.visibility = View.VISIBLE
        } else {
            ctaView.text = "INSTALL NOW"
            ctaView.visibility = View.VISIBLE
        }
        adView.callToActionView = ctaView

        // Icon
        if (nativeAd.icon?.drawable != null) {
            iconView.setImageDrawable(nativeAd.icon?.drawable)
            iconView.visibility = View.VISIBLE
        } else {
            iconView.visibility = View.GONE
        }
        adView.iconView = iconView

        adView.mediaView = mediaView

        adView.setNativeAd(nativeAd)
        return adView
    }
}
