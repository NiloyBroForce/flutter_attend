plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    // REQUIRED: Google Services Plugin for Firebase / Google Sign-In
    id("com.google.gms.google-services")
}

android {
    namespace = "com.niloy.demo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.niloy.demo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
        ndk {
            abiFilters.addAll(setOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
          isMinifyEnabled = false    // ✅ Correct Kotlin DSL property
        isShrinkResources = false  // ✅ Correct Kotlin DSL property
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}