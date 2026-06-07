import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val kakaoNativeAppKey = (
    localProperties.getProperty("kakao.native_app_key")
        ?: providers.gradleProperty("kakao.native_app_key").orNull
        ?: providers.environmentVariable("KAKAO_NATIVE_APP_KEY").orNull
        ?: ""
).trim()
val kakaoNativeAppKeyScheme =
    if (kakaoNativeAppKey.isBlank()) "kakaoYOUR_NATIVE_APP_KEY" else "kakao$kakaoNativeAppKey"
val escapedKakaoNativeAppKey =
    kakaoNativeAppKey.replace("\\", "\\\\").replace("\"", "\\\"")

android {
    namespace = "com.example.magicsorafront"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.magicsorafront"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["kakaoNativeAppKeyScheme"] = kakaoNativeAppKeyScheme
        buildConfigField("String", "KAKAO_NATIVE_APP_KEY", "\"$escapedKakaoNativeAppKey\"")
    }

    signingConfigs {
        create("sharedDebug") {
            storeFile = file("shared-debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("sharedDebug")
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
