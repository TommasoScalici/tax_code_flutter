# Keep all Wearable classes
-keep class com.google.android.wearable.** { *; }
-keep interface com.google.android.wearable.** { *; }

# Keep specific classes that are being reported as missing
-keep class com.google.android.wearable.compat.WearableActivityController { *; }
-keep class com.google.android.wearable.compat.WearableActivityController$AmbientCallback { *; }

# Keep all classes in the flutterwear package
-keep class com.mjohnsullivan.flutterwear.** { *; }