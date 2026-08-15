plugins {
    id("com.android.application")
    id("kotlin-android")
    // Firebase. Must come before the Flutter plugin.
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin
    // Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.tebiyu.tebiyu"
    compileSdk = flutter.compileSdkVersion

    // Pinned rather than taking flutter.ndkVersion. The Firebase plugins are
    // built against this NDK, and a mismatch fails the build with an error
    // that does not name the real cause.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // Lets older Android versions use newer Java APIs that some Firebase
        // dependencies rely on.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.tebiyu.tebiyu"

        // firebase_auth requires 23, and google_sign_in 7.x uses Credential
        // Manager which also needs 23. Flutter's default is lower, so this is
        // set explicitly rather than inherited.
        //
        // Worth knowing for the South Sudan market: this drops Android 5.x
        // devices, roughly 1 to 2 percent of active Android handsets. Firebase
        // Auth is not usable below it, so the floor is not really a choice.
        minSdk = 23

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Firebase pushes the app past the 64k method limit on older devices.
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Replace with a real signing config before the Play Store build
            // in P6.6. Debug signing is here only so `flutter run --release`
            // works during development.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
