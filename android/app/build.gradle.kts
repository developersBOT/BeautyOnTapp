import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.isFile) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)
}

fun releaseSigningValue(propertyName: String, environmentName: String): String? {
    return keystoreProperties.getProperty(propertyName)?.takeIf(String::isNotBlank)
        ?: System.getenv(environmentName)?.takeIf(String::isNotBlank)
}

val releaseStoreFile = releaseSigningValue("storeFile", "BOT_ANDROID_STORE_FILE")
val releaseStorePassword =
    releaseSigningValue("storePassword", "BOT_ANDROID_STORE_PASSWORD")
val releaseKeyAlias = releaseSigningValue("keyAlias", "BOT_ANDROID_KEY_ALIAS")
val releaseKeyPassword =
    releaseSigningValue("keyPassword", "BOT_ANDROID_KEY_PASSWORD")
val releaseSigningConfigured =
    listOf(
        releaseStoreFile,
        releaseStorePassword,
        releaseKeyAlias,
        releaseKeyPassword,
    ).all { it != null }
val releaseArtifactTaskNames =
    setOf(
        "assembleRelease",
        "bundleRelease",
        "installRelease",
        "packageRelease",
        "signReleaseBundle",
    )
val appProjectPath = project.path

gradle.taskGraph.whenReady {
    val releaseArtifactRequested =
        allTasks.any { task ->
            task.project.path == appProjectPath && task.name in releaseArtifactTaskNames
        }

    if (releaseArtifactRequested && !releaseSigningConfigured) {
        throw GradleException(
            "Release signing is not configured. Add android/key.properties with " +
                "storeFile, storePassword, keyAlias, and keyPassword, or set the " +
                "BOT_ANDROID_STORE_FILE, BOT_ANDROID_STORE_PASSWORD, " +
                "BOT_ANDROID_KEY_ALIAS, and BOT_ANDROID_KEY_PASSWORD environment variables.",
        )
    }

    if (
        releaseArtifactRequested &&
        releaseStoreFile != null &&
        !rootProject.file(releaseStoreFile).isFile
    ) {
        throw GradleException(
            "Release keystore not found at ${rootProject.file(releaseStoreFile)}.",
        )
    }
}

android {
    namespace = "app.shopbeautyontapp.co.za"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Set to the highest NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "app.shopbeautyontapp.co.za"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 4
        versionName = "1.4.3"
    }

    signingConfigs {
        if (releaseSigningConfigured) {
            create("release") {
                storeFile = rootProject.file(requireNotNull(releaseStoreFile))
                storePassword = requireNotNull(releaseStorePassword)
                keyAlias = requireNotNull(releaseKeyAlias)
                keyPassword = requireNotNull(releaseKeyPassword)
            }
        }
    }

    buildTypes {
        release {
            signingConfigs.findByName("release")?.let {
                signingConfig = it
            }
        }
    }
}

flutter {
    source = "../.."
}
