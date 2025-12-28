# ============================================================
# CLUCK RUSH - ProGuard Rules
# ============================================================
# These rules are used by R8 (Android's code shrinker) during
# release builds to optimize the app and remove unused code.
# ============================================================

# ============================================================
# FLUTTER RULES
# ============================================================

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ============================================================
# GOOGLE PLAY CORE - DEFERRED COMPONENTS
# ============================================================
# Flutter's Android build may reference Google Play Core classes
# for deferred components (dynamic feature modules). If the app
# doesn't use this feature and doesn't include the Play Core
# library, R8 will fail because it cannot find those classes.
#
# These -dontwarn rules tell R8 to ignore the missing classes,
# which is safe because deferred components are not used.
# ============================================================

-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Additional Play Core classes that might be referenced
-dontwarn com.google.android.play.core.**

# ============================================================
# HIVE CE (Local Storage)
# ============================================================

# Keep Hive type adapters
-keep class * extends hive_ce.TypeAdapter { *; }
-keep @hive_ce.HiveType class * { *; }

# ============================================================
# FLAME ENGINE (Game Framework)
# ============================================================

# Keep Flame components
-keep class org.libsdl.app.** { *; }

# ============================================================
# AUDIOPLAYERS
# ============================================================

# Keep audioplayers native code
-keep class xyz.luan.audioplayers.** { *; }

# ============================================================
# GENERAL ANDROID RULES
# ============================================================

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# ============================================================
# KOTLIN
# ============================================================

# Keep Kotlin metadata
-keepattributes *Annotation*
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations

# Kotlin coroutines
-dontwarn kotlinx.coroutines.**

# ============================================================
# DEBUGGING (Remove in production if not needed)
# ============================================================

# Keep line numbers for stack traces
-keepattributes SourceFile,LineNumberTable

# If you want to hide the original source file name
# -renamesourcefileattribute SourceFile

