# ==============================================================================
# R8 / ProGuard Optimization Rules for Tax Code Mobile
# ==============================================================================

# Crashlytics: Preserve line numbers and source files for de-obfuscation in Firebase Console
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Flutter View & Accessibility Bridge (prevents ClassNotFoundException in AccessibilityBridge)
-keep class io.flutter.view.** { *; }

# Google Sign-In & Auth Parcelables (prevents NullPointerException in SignInHubActivity)
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Serialization & Reflection: Preserve annotations and generic signatures
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Kotlin
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings { <fields>; }

# Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-dontwarn kotlinx.coroutines.**

# Warnings suppression for optional / transitive dependencies
-dontwarn io.flutter.embedding.**
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn androidx.camera.**
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

