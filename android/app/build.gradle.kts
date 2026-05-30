plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.deaf.deaf"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // ✅ Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.deaf.deaf"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ✅ IMPORTANT: Use coreLibraryDesugaring, NOT implementation
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")

    // ✅ Force Gradle to pull the Flutter embedding dependency into the classpath
}

// ✅ DYNAMIC FALLBACK HOOK:
// Listens for the build task to be added by the Flutter plugin dynamically,
// then injects the APK copier to satisfy the high-level Flutter runner.
tasks.whenTaskAdded {
    if (name == "assembleDebug") {
        doLast {
            val srcFile = file("${project.layout.buildDirectory.get()}/outputs/apk/debug/app-debug.apk")
            val dstDir = file("${project.rootDir}/../build/app/outputs/flutter-apk")

            if (srcFile.exists()) {
                mkdir(dstDir)
                srcFile.copyTo(file("$dstDir/app-debug.apk"), overwrite = true)
                println("====== ✅ Successfully matched APK path for Flutter Tooling ======")
            } else {
                println("====== ⚠️ Source APK not found at: ${srcFile.absolutePath} ======")
            }
        }
    }
}