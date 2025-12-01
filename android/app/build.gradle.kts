import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// TRY to load keystore, but ignore if missing
val keystoreProperties = Properties()
val keystoreFile = rootProject.file("key.properties")
val hasKeystore = keystoreFile.exists()

if (hasKeystore) {
    keystoreProperties.load(FileInputStream(keystoreFile))
}

android {
    namespace = "com.hogostudios.glowandgo"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.hogostudios.glowandgo"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasKeystore) {
                keyAlias = keystoreProperties["keyAlias"]?.toString()
                keyPassword = keystoreProperties["keyPassword"]?.toString()
                storeFile = file(keystoreProperties["storeFile"]?.toString())
                storePassword = keystoreProperties["storePassword"]?.toString()
            }
        }
    }

    buildTypes {
        getByName("release") {
            // USE DEBUG SIGNING IF KEYSTORE IS MISSING
            signingConfig = if (hasKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // disable shrinking when no keystore
            isShrinkResources = hasKeystore
            isMinifyEnabled = hasKeystore

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
