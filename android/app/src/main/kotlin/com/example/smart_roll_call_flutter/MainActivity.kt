package com.example.smart_roll_call_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register plugins
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
    
    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        // Handle low memory conditions
        if (level == TRIM_MEMORY_RUNNING_CRITICAL || level == TRIM_MEMORY_RUNNING_LOW) {
            // Clear caches or release resources
            System.gc()
        }
    }
}
