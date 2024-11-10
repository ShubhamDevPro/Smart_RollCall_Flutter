# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }

# Keep Flutter plugins
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# Enable R8 full mode optimizations
-allowaccessmodification
-repackageclasses 