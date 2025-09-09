apply(plugin = "com.google.gms.google-services")
// filepath: c:\Desktop\fitgen\fitgen\android\app\build.gradle.kts
// ...existing code...
apply(plugin = "com.google.gms.google-services")

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") version "4.4.3" apply false
}

android {
    namespace = "com.example.fitgen"
    compileSdk = 35 // Set your desired compileSdk version
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.fitgen"
        minSdk = flutter.minSdkVersion
        targetSdk = 35 // Set your desired targetSdk version
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
