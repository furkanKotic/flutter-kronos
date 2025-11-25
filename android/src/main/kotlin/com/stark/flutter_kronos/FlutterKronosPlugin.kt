package com.stark.flutter_kronos

import com.lyft.kronos.AndroidClockFactory
import com.lyft.kronos.KronosClock

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FlutterKronosPlugin */
class FlutterKronosPlugin : MethodCallHandler, FlutterPlugin, ActivityAware {

    private var kronosClock: KronosClock? = null
    private var channel: MethodChannel? = null

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "SYNC" -> {
                kronosClock?.syncInBackground()
            }
            "GET_CURRENT_TIME_MS" -> {
                result.success(kronosClock?.getCurrentTimeMs());
            }
            "GET_CURRENT_NTP_TIME_MS" -> {
                result.success(kronosClock?.getCurrentNtpTimeMs());
            }
            else -> {
                result.notImplemented()
            }
        }
        return Unit
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // no op
        val messenger = binding.getBinaryMessenger()
        channel = MethodChannel(messenger, "flutter_kronos")
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // no op
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        kronosClock = AndroidClockFactory.createKronosClock(binding.getActivity())
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
