import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Release imzosi: android/key.properties (git'ga qo'shilmaydi). Namuna: key.properties.example
val keystoreProps = Properties()
val keystoreFile = rootProject.file("key.properties")
val hasKeystore = keystoreFile.exists()
if (hasKeystore) {
    keystoreFile.inputStream().use { keystoreProps.load(it) }
}

android {
    namespace = "uz.shirinliklar.app"
    // Google Play: yangi ilova va yangilanishlar Android 16 (API 36) ga mo'ljallangan bo'lishi shart.
    compileSdk = maxOf(flutter.compileSdkVersion, 36)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "uz.shirinliklar.app"
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = 36
        // Versiya pubspec.yaml dagi version: 1.0.0+1 dan olinadi (versionName + versionCode).
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasKeystore) {
            create("release") {
                storeFile = file(keystoreProps.getProperty("storeFile"))
                storePassword = keystoreProps.getProperty("storePassword")
                keyAlias = keystoreProps.getProperty("keyAlias")
                keyPassword = keystoreProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Kodni kichraytirish va ishlatilmaydigan resurslarni olib tashlash.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            if (hasKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

// Release'ni debug kaliti bilan chiqarib yuborib bo'lmaydi: key.properties bo'lmasa build to'xtaydi.
gradle.taskGraph.whenReady {
    val releaseBuild = allTasks.any {
        it.project == project && (it.name == "assembleRelease" || it.name == "bundleRelease" || it.name == "packageRelease")
    }
    if (releaseBuild && !hasKeystore) {
        throw GradleException("Release imzolash sozlanmagan: android/key.properties yarating (key.properties.example ga qarang).")
    }
}

flutter {
    source = "../.."
}
