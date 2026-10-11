# ==============================================================================
# R8 / ProGuard Optimization Rules for Tax Code Wear OS
# ==============================================================================

# Crashlytics: Preserve line numbers and source files for de-obfuscation in Firebase Console
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Flutter Engine & Embedding
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Services & Auth
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.auth.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.crashlytics.** { *; }
-keep class com.google.firebase.appcheck.** { *; }

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
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

