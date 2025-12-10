# Flutter wrapper - Keep all Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Ignore Google Play Core classes (not needed unless using deferred components)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Keep Flutter plugins
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.plugin.platform.** { *; }

# Keep all native methods
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Gson (used by json_serializable)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep all model classes (for JSON serialization)
-keep class com.example.ainnect.models.** { *; }

# Keep json_annotation classes
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Keep all classes with @JsonSerializable annotation
-keep @interface com.google.gson.annotations.SerializedName
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Preserve all native method names and the names of their classes
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes that are used in reflection
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# OkHttp3
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Retrofit (if used)
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Exceptions

# WebSocket
-keep class org.java_websocket.** { *; }
-dontwarn org.java_websocket.**

# Keep generic signature of Call, Response (R8 full mode)
-keepattributes Signature

# Keep R8 from removing annotations
-keepattributes *Annotation*,Signature,Exception

# Prevent obfuscation of models
-keep class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep custom model classes
-keep class com.example.ainnect.** { *; }

# Keep specific Flutter plugins used in the project
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class dev.steenbakker.mobile_scanner.** { *; }
-keep class io.flutter.plugins.videoplayer.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class io.flutter.plugins.packageinfo.** { *; }

# Keep WebSocket and STOMP client classes
-keep class org.hildan.** { *; }
-dontwarn org.hildan.**

# Keep video player and Chewie
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Additional Flutter embedding rules
-keep class androidx.lifecycle.** { *; }
-keep class androidx.fragment.app.** { *; }

# Keep MethodChannel and EventChannel
-keepclassmembers class * {
    @io.flutter.embedding.engine.dart.DartExecutor.DartCallback *;
}

# Prevent stripping of Flutter JNI methods
-keepclassmembers class * {
    native <methods>;
}

# Keep line numbers for debugging stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep MainActivity and Application class
-keep class com.example.ainnect.MainActivity { *; }
-keep class com.example.ainnect.** { *; }

# Keep all Activities, Services, Receivers
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.Application

# Keep AndroidX classes
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# Keep Google classes
-keep class com.google.** { *; }
-dontwarn com.google.**

# Prevent crash on launch
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}

# Keep Flutter Application class
-keep class io.flutter.app.FlutterApplication { *; }
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class io.flutter.embedding.android.FlutterFragmentActivity { *; }

# Additional rules to prevent crashes
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep HTTP and network related classes
-keep class java.net.** { *; }
-keep class javax.net.ssl.** { *; }
-keep class javax.net.** { *; }
-dontwarn java.net.**
-dontwarn javax.net.ssl.**
-dontwarn javax.net.**

# Keep all classes used by Flutter HTTP plugin
-keep class io.flutter.plugins.connectivity.** { *; }
-keep class io.flutter.plugins.networkinfo.** { *; }
-dontwarn io.flutter.plugins.connectivity.**
-dontwarn io.flutter.plugins.networkinfo.**

# Keep certificate and SSL classes
-keep class java.security.cert.** { *; }
-keep class javax.security.** { *; }
-dontwarn java.security.cert.**
-dontwarn javax.security.**
