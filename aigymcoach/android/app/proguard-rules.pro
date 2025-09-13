# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_blue_plus
-keep class com.boskokg.flutter_blue_plus.** { *; }
-keep class com.lib.flutter_blue_plus.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Your app classes
-keep class com.example.fitgen.** { *; }

# ML Kit
-keep class com.google.android.gms.** { *; }
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.odml.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Prevent R8 from stripping interface information
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

 #  Add this line to ignore warnings (for camera_web issue)
-ignorewarnings

# Explicitly keep default constructors (Recommended for future R8)
-keepclassmembers class com.google.vending.licensing.ILicensingService { 
    void <init>(); 
}
-keepclassmembers class com.android.vending.licensing.ILicensingService { 
    void <init>(); 
}
-keepclassmembers class com.google.android.vending.licensing.ILicensingService { 
    void <init>(); 
}
-keepclassmembers class android.support.annotation.Keep { 
    void <init>(); 
}
-keepclassmembers class androidx.lifecycle.DefaultLifecycleObserver{
     void <init>();
}
 -keepclassmembers class com.google.android.apps.common.proguard.UsedBy*{
     void <init>();
}
-keepclassmembers class * extends androidx.work.Worker{
     void <init>();
}
-keepclassmembers class * extends androidx.work.InputMerger{
     void <init>();
}
-keepclassmembers class androidx.work.WorkerParameters{
     void <init>();
}
-keepclassmembers class com.google.android.gms.common.internal.ReflectedParcelable{
     void <init>();
}
-keepclassmembers class * implements com.google.android.gms.common.internal.ReflectedParcelable{
     void <init>();
}
 -keepclassmembers interface android.support.annotation.Keep{
     void <init>();
}
 -keepclassmembers class * implements android.support.annotation.Keep{
     void <init>();
}
 -keepclassmembers interface androidx.annotation.Keep{
     void <init>();
}
 -keepclassmembers class * implements androidx.annotation.Keep{
     void <init>();
}
 -keepclassmembers interface com.google.android.gms.common.annotation.KeepName{
     void <init>();
}
 -keepclassmembers class * implements com.google.android.gms.common.annotation.KeepName{
     void <init>();
}
 -keepclassmembers interface com.google.android.gms.common.util.DynamiteApi{
     void <init>();
}
 -keepclassmembers class * extends androidx.startup.Initializer{
     void <init>();
}
 -keepclassmembers class * extends androidx.room.RoomDatabase{
     void <init>();
}
 -keepclassmembers class * implements androidx.versionedparcelable.VersionedParcelable{
     void <init>();
}
 -keepclassmembers public class androidx.versionedparcelable.ParcelImpl{
     void <init>();
}
 -keepclassmembers class * implements com.google.firebase.components.ComponentRegistrar{
     void <init>();
}
 -keepclassmembers interface com.google.firebase.components.ComponentRegistrar{
     void <init>();
}
 -keepclassmembers interface androidx.annotation.Keep{
     void <init>();
}
-keepclassmembers class com.google.android.odml.** {
    void <init>();
}
