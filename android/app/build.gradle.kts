import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.puzzle_world"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(
                org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
            )
        }
    }

    defaultConfig {
        applicationId = "com.example.puzzle_world"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ============================================================
    // Release Signing
    // ============================================================

    signingConfigs {
        create("release") {
            val keystorePropertiesFile =
                rootProject.file("key.properties")

            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()

                keystorePropertiesFile.inputStream().use {
                    keystoreProperties.load(it)
                }

                val storeFilePath =
                    keystoreProperties.getProperty("storeFile")

                val storePasswordValue =
                    keystoreProperties.getProperty("storePassword")

                val keyAliasValue =
                    keystoreProperties.getProperty("keyAlias")

                val keyPasswordValue =
                    keystoreProperties.getProperty("keyPassword")

                if (
                    storeFilePath != null &&
                    storePasswordValue != null &&
                    keyAliasValue != null &&
                    keyPasswordValue != null
                ) {
                    storeFile = file(storeFilePath)

                    storePassword = storePasswordValue

                    keyAlias = keyAliasValue

                    keyPassword = keyPasswordValue
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                signingConfigs.getByName("release")

            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}