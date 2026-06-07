plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties (opcional — para release builds)
val keyPropertiesFile = rootProject.file("key.properties")
val hasKeyProperties = keyPropertiesFile.exists()
val keyProperties = java.util.Properties()
if (hasKeyProperties) {
    keyProperties.load(java.io.FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.altardiario.altar_diario"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.altardiario.altar_diario"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (hasKeyProperties) {
        signingConfigs {
            create("release") {
                keyAlias = keyProperties["keyAlias"] as String
                keyPassword = keyProperties["keyPassword"] as String
                storeFile = keyProperties["storeFile"]?.let { file(it) }
                storePassword = keyProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (hasKeyProperties) {
                signingConfig = signingConfigs["release"]!!
                isMinifyEnabled = true
            } else {
                isMinifyEnabled = false
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation("com.google.android.play:core:1.10.3")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
