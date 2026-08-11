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

    defaultConfig {
        applicationId = "com.example.puzzle_world"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile =
                rootProject.file("key.properties")

            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()

                keystorePropertiesFile.inputStream().use {
                    keystoreProperties.load(it)
                }

                storeFile = file(
                    keystoreProperties.getProperty("storeFile")
                )

                storePassword =
                    keystoreProperties.getProperty("storePassword")

                keyAlias =
                    keystoreProperties.getProperty("keyAlias")

                keyPassword =
                    keystoreProperties.getProperty("keyPassword")
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

    // Kotlin JVM 17
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(
                org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
            )
        }
    }
}

flutter {
    source = "../.."
}