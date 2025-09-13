// Root-level build.gradle.kts
import java.io.File // Import the File class



buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("com.google.gms:google-services:4.4.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File(rootProject.rootDir, "../build") // Use File constructor

subprojects {
     project.buildDir = File(rootProject.buildDir, project.name) // Use File constructor
    //  Removed: project.evaluationDependsOn(':app')  // Not needed in Kotlin DSL and can cause issues.
}


tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}