# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

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
