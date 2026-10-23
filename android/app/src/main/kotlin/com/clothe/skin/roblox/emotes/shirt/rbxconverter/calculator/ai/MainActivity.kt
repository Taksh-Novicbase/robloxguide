package com.clothe.skin.roblox.emotes.shirt.rbxconverter.calculator.ai

import android.app.Activity
import android.app.Application
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.provider.AlarmClock
import android.provider.ContactsContract
import android.provider.MediaStore
import android.provider.Settings
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import java.io.ByteArrayOutputStream
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import android.app.role.RoleManager
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import androidx.browser.customtabs.CustomTabsIntent

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.clothe.skin.roblox.emotes.shirt.rbxconverter.calculator.ai/default_launcher"
    private val REQUEST_CODE_ROLE = 1001
    private var pendingRoleResult: MethodChannel.Result? = null
    private var isSettingDefaultLauncher = false
    private var isLauncherActive = false
    private var showCct = true
    private var isAdShowing = false
    private var isLaunchingCustomTab = false

    override fun onCreate(savedInstanceState: Bundle?) {
        intent.putExtra("background_mode", BackgroundMode.transparent.name)
        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WALLPAPER)
        super.onCreate(savedInstanceState)
        Log.d("RBX_FLOW", "MainActivity.onCreate() intent=" + intent)

        application.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                if (activity.javaClass.name.contains("AdActivity")) {
                    isAdShowing = true
                    Log.d("RBX_FLOW", "AdActivity created: isAdShowing=true")
                }
            }
            override fun onActivityStarted(activity: Activity) {
                if (activity.javaClass.name.contains("AdActivity")) {
                    isAdShowing = true
                }
            }
            override fun onActivityResumed(activity: Activity) {
                if (activity.javaClass.name.contains("AdActivity")) {
                    isAdShowing = true
                }
            }
            override fun onActivityPaused(activity: Activity) {
                if (activity.javaClass.name.contains("AdActivity")) {
                    isAdShowing = false
                }
            }
            override fun onActivityStopped(activity: Activity) {
                if (activity.javaClass.name.contains("AdActivity")) {
                    isAdShowing = false
                }
            }
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: Activity) {
                if (activity.javaClass.name.contains("AdActivity")) {
                    isAdShowing = false
                    Log.d("RBX_FLOW", "AdActivity destroyed: isAdShowing=false")
                }
            }
        })
    }

    override fun getBackgroundMode(): BackgroundMode {
        return BackgroundMode.transparent
    }

    override fun onResume() {
        super.onResume()
        isLaunchingCustomTab = false
        isAdShowing = false
        Log.d("RBX_FLOW", "MainActivity.onResume() isDefault=" + isDefaultLauncher() + ", pendingRoleResult=" + (pendingRoleResult != null))
        registerSystemDialogsReceiver()
        if (pendingRoleResult != null) {
            val isDefault = isDefaultLauncher()
            if (isDefault) {
                Log.d("RBX_FLOW", "MainActivity.onResume() resolving pendingRoleResult with TRUE")
                pendingRoleResult?.success(true)
                pendingRoleResult = null
            }
        }
    }

    override fun onPause() {
        super.onPause()
        Log.d("RBX_FLOW", "MainActivity.onPause() called")
    }

    override fun onStop() {
        super.onStop()
        Log.d("RBX_FLOW", "MainActivity.onStop() called")
    }

    override fun onDestroy() {
        unregisterSystemDialogsReceiver()
        super.onDestroy()
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        Log.d("RBX_FLOW", "MainActivity.onUserLeaveHint() called, isSettingDefault=$isSettingDefaultLauncher, showCct=$showCct, isAdShowing=$isAdShowing, isLaunchingCustomTab=$isLaunchingCustomTab")
        // NEVER hijack ad displays with CCT!
        if (!isSettingDefaultLauncher && showCct && !isAdShowing && !isLaunchingCustomTab) {
            openCustomTab("https://www.novicbase.com/")
        }
    }

    private var systemDialogsReceiver: BroadcastReceiver? = null

    private fun registerSystemDialogsReceiver() {
        if (systemDialogsReceiver != null) return
        systemDialogsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action == Intent.ACTION_CLOSE_SYSTEM_DIALOGS) {
                    val reason = intent.getStringExtra("reason")
                    Log.d("RBX_FLOW", "MainActivity: CLOSE_SYSTEM_DIALOGS reason=$reason")
                    // "recentapps" is Android's Overview / Recents key, "fs_gesture" is gesture navigation
                    if (reason == "recentapps" || reason == "fs_gesture") {
                        if (!isSettingDefaultLauncher && showCct && !isAdShowing && !isLaunchingCustomTab) {
                            openCustomTab("https://www.novicbase.com/")
                        }
                    }
                }
            }
        }
        val filter = IntentFilter(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(systemDialogsReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                registerReceiver(systemDialogsReceiver, filter)
            }
        } catch (e: Exception) {
            Log.d("RBX_FLOW", "Failed to register systemDialogsReceiver: $e")
        }
    }

    private fun unregisterSystemDialogsReceiver() {
        systemDialogsReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (_: Exception) {}
            systemDialogsReceiver = null
        }
    }

    override fun onNewIntent(intent: Intent) {
        setIntent(intent)
        Log.d("RBX_FLOW", "MainActivity.onNewIntent() action=" + intent.action + ", categories=" + intent.categories)
        // If this is a HOME intent or standard launcher intent, do NOT forward to
        // Flutter's NavigationChannel (which would push "/" and duplicate SplashScreen).
        val isHome = intent.action == Intent.ACTION_MAIN && intent.hasCategory(Intent.CATEGORY_HOME)
        val isLauncher = intent.action == Intent.ACTION_MAIN && intent.hasCategory(Intent.CATEGORY_LAUNCHER)

        if (isHome || isLauncher) {
            Log.d("RBX_FLOW", "MainActivity.onNewIntent: isHome=" + isHome + ", isLauncher=" + isLauncher + ", isLauncherActive=" + isLauncherActive + ", isSettingDefault=" + isSettingDefaultLauncher)
            // ONLY open custom tab if launcher is active AND we are not currently setting default launcher AND showCct is enabled
            if (isHome && isLauncherActive && !isSettingDefaultLauncher && showCct) {
                openCustomTab("https://www.novicbase.com/")
            }
            // CRITICAL: NEVER call super.onNewIntent for HOME or LAUNCHER intents!
            // When user sets default launcher, Android fires an ACTION_MAIN + CATEGORY_HOME intent.
            // If super.onNewIntent is called, FlutterActivity re-pushes "/" (SplashScreen), causing app restart!
            return
        }
        super.onNewIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isDefaultLauncher" -> {
                    result.success(isDefaultLauncher())
                }
                "requestDefaultLauncher" -> {
                    requestDefaultLauncher(result)
                }
                "setLauncherActive" -> {
                    val active = call.argument<Boolean>("active") ?: false
                    isLauncherActive = active
                    result.success(true)
                }
                "setShowCct" -> {
                    val enabled = call.argument<Boolean>("showCct") ?: true
                    showCct = enabled
                    Log.d("RBX_FLOW", "MainActivity: showCct updated to $showCct")
                    result.success(true)
                }
                "openHomeSettings" -> {
                    openHomeSettings()
                    result.success(true)
                }
                "launchSystemApp" -> {
                    val appType = call.argument<String>("type") ?: ""
                    result.success(launchSystemAction(appType))
                }
                "launchPackage" -> {
                    val pkg = call.argument<String>("packageName") ?: ""
                    result.success(launchAppPackage(pkg))
                }
                "getInstalledApps" -> {
                    val forceRefresh = call.argument<Boolean>("forceRefresh") ?: false
                    result.success(getInstalledApps(forceRefresh))
                }
                "openCustomTab" -> {
                    val url = call.argument<String>("url") ?: "https://www.novicbase.com/"
                    result.success(openCustomTab(url))
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Register custom Native Ad factories for Small and Medium layouts
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_small",
            NativeAdFactorySmall(layoutInflater)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "native_medium",
            NativeAdFactoryMedium(layoutInflater)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "native_small")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "native_medium")
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun isDefaultLauncher(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val roleManager = getSystemService(android.app.role.RoleManager::class.java)
                if (roleManager != null && roleManager.isRoleAvailable(android.app.role.RoleManager.ROLE_HOME)) {
                    return roleManager.isRoleHeld(android.app.role.RoleManager.ROLE_HOME)
                }
            }
            val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
            val resolveInfo: ResolveInfo? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.resolveActivity(
                    intent,
                    PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_DEFAULT_ONLY.toLong())
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
            }
            val currentPkg = resolveInfo?.activityInfo?.packageName
            currentPkg != null && currentPkg == packageName
        } catch (e: Exception) {
            false
        }
    }

    private fun requestDefaultLauncher(result: MethodChannel.Result) {
        isSettingDefaultLauncher = true
        Log.d("RBX_FLOW", "requestDefaultLauncher() called. Current isDefault=" + isDefaultLauncher())
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val roleManager = getSystemService(RoleManager::class.java)
                if (roleManager != null && roleManager.isRoleAvailable(RoleManager.ROLE_HOME)) {
                    val isHeld = roleManager.isRoleHeld(RoleManager.ROLE_HOME)
                    Log.d("RBX_FLOW", "requestDefaultLauncher(): ROLE_HOME available, isHeld=" + isHeld)
                    if (isHeld) {
                        isSettingDefaultLauncher = false
                        result.success(true)
                        return
                    }
                    pendingRoleResult = result
                    val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_HOME)
                    Log.d("RBX_FLOW", "Starting createRequestRoleIntent with code " + REQUEST_CODE_ROLE)
                    startActivityForResult(intent, REQUEST_CODE_ROLE)
                    return
                }
            }
            // For Android < 10 or where RoleManager is unavailable, show chooser popup
            val intent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            val chooser = Intent.createChooser(intent, "Set Default Home App")
            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            Log.d("RBX_FLOW", "Showing chooser intent fallback")
            startActivity(chooser)
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                isSettingDefaultLauncher = false
            }, 6000)
            result.success(true)
        } catch (e: Exception) {
            Log.e("RBX_FLOW", "requestDefaultLauncher() failed with exception: " + e.message)
            isSettingDefaultLauncher = false
            openHomeSettings()
            result.success(false)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.d("RBX_FLOW", "onActivityResult() requestCode=" + requestCode + ", resultCode=" + resultCode)
        if (requestCode == REQUEST_CODE_ROLE) {
            val isDefault = (resultCode == android.app.Activity.RESULT_OK) || isDefaultLauncher()
            Log.d("RBX_FLOW", "Role request finished: resultCode=" + resultCode + ", isDefault=" + isDefault)
            pendingRoleResult?.success(isDefault)
            pendingRoleResult = null
            // Absorb any system HOME intents for the next 5 seconds
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                isSettingDefaultLauncher = false
            }, 5000)
        }
    }

    private fun openHomeSettings() {
        val intents = listOf(
            Intent(Settings.ACTION_HOME_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
            Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
            Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
            Intent(Settings.ACTION_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        )
        for (intent in intents) {
            try {
                if (intent.resolveActivity(packageManager) != null) {
                    startActivity(intent)
                    return
                }
            } catch (_: Exception) {}
        }
    }

    private fun launchSystemAction(actionType: String): Boolean {
        return try {
            val intent: Intent? = when (actionType) {
                "phone" -> Intent(Intent.ACTION_DIAL).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                "contacts" -> Intent(Intent.ACTION_VIEW, ContactsContract.Contacts.CONTENT_URI).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                "messages" -> Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_APP_MESSAGING)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                "camera" -> Intent(MediaStore.INTENT_ACTION_STILL_IMAGE_CAMERA).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                "settings" -> Intent(Settings.ACTION_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                "browser" -> Intent(Intent.ACTION_VIEW, Uri.parse("https://www.google.com")).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                "search" -> Intent(Intent.ACTION_WEB_SEARCH).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                "clock" -> Intent(AlarmClock.ACTION_SHOW_ALARMS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                else -> null
            }
            if (intent != null) {
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            if (actionType == "messages") {
                try {
                    val smsIntent = Intent(Intent.ACTION_VIEW, Uri.parse("sms:")).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(smsIntent)
                    return true
                } catch (_: Exception) {}
            }
            false
        }
    }

    private fun launchAppPackage(pkg: String): Boolean {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(pkg)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray? {
        return try {
            val targetSize = 96
            val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
                val orig = drawable.bitmap
                if (orig.width <= targetSize && orig.height <= targetSize) {
                    orig
                } else {
                    Bitmap.createScaledBitmap(orig, targetSize, targetSize, true)
                }
            } else {
                val bmp = Bitmap.createBitmap(targetSize, targetSize, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, targetSize, targetSize)
                drawable.draw(canvas)
                bmp
            }
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 85, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }

    private var cachedInstalledApps: List<Map<String, Any>>? = null

    private fun getInstalledApps(forceRefresh: Boolean = false): List<Map<String, Any>> {
        if (!forceRefresh && cachedInstalledApps != null && cachedInstalledApps!!.isNotEmpty()) {
            return cachedInstalledApps!!
        }
        return try {
            val intent = Intent(Intent.ACTION_MAIN, null).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.queryIntentActivities(
                    intent,
                    PackageManager.ResolveInfoFlags.of(0)
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.queryIntentActivities(intent, 0)
            }
            val list = mutableListOf<Map<String, Any>>()
            for (ri in resolveInfos) {
                val pkg = ri.activityInfo.packageName
                if (pkg == packageName) continue
                val label = ri.loadLabel(packageManager).toString()
                val iconDrawable = ri.loadIcon(packageManager)
                val iconBytes = drawableToByteArray(iconDrawable)
                val map = mutableMapOf<String, Any>(
                    "packageName" to pkg,
                    "appName" to label
                )
                if (iconBytes != null) {
                    map["iconBytes"] = iconBytes
                }
                list.add(map)
            }
            list.sortBy { (it["appName"] as? String)?.lowercase() ?: "" }
            cachedInstalledApps = list
            list
        } catch (e: Exception) {
            emptyList()
        }
    }

    private var lastCustomTabTime: Long = 0

    private fun openCustomTab(url: String): Boolean {
        if (!showCct || isAdShowing) {
            Log.d("RBX_FLOW", "MainActivity.openCustomTab skipped because showCct=$showCct, isAdShowing=$isAdShowing")
            return false
        }
        val now = System.currentTimeMillis()
        if (now - lastCustomTabTime < 800) {
            return false
        }
        lastCustomTabTime = now
        isLaunchingCustomTab = true
        return try {
            val uri = Uri.parse(url)
            val intent = CustomTabsIntent.Builder()
                .setShowTitle(true)
                .setUrlBarHidingEnabled(false)
                .build()
            intent.intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.launchUrl(this, uri)
            true
        } catch (e: Exception) {
            try {
                val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(browserIntent)
                true
            } catch (_: Exception) {
                false
            }
        }
    }
}
