// app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Apply the ML Kit commons fix
apply(from = "${rootProject.projectDir}/mlkit_commons_fix.gradle")

android {
    namespace = "com.example.fitgen"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.fitgen"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

     // Updated variant configuration
    applicationVariants.all { 
    val variant = this
    tasks.named("assemble${variant.name.capitalize()}").configure {
        doLast {
            copy {
                from("${project.buildDir}/outputs/apk/${variant.name}/app-${variant.name}.apk")
                into("${project.buildDir}/outputs/apk")
            }
        }
    }
    }
}






flutter {
    source = "../.."
}

dependencies {
    // Add your dependencies here if needed
}