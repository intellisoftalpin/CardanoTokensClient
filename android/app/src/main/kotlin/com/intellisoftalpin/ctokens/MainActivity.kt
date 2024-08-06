package com.intellisoftalpin.ctokens

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.engine.FlutterEngine
import android.os.Bundle
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    private fun pathing() {
        if (intent.getIntExtra("org.chromium.chrome.extra.TASK_ID", -1) == this.taskId) {
            this.finish()
            intent.addFlags(FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    override fun onResume() {
        pathing()
        super.onResume()
    }

    override fun onRestart() {
        pathing()
        super.onRestart()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        pathing()
        super.onCreate(savedInstanceState)
    }
}
