plugins {
  id("com.android.library")
  id("org.jetbrains.kotlin.plugin.compose")
  id("maven-publish")
}

android {
  namespace = "jp.co.altive.chat"
  compileSdk = 37

  defaultConfig {
    minSdk = 26
    consumerProguardFiles("consumer-rules.pro")
    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
  }

  buildFeatures { compose = true }

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
  }

  testOptions { unitTests.isIncludeAndroidResources = true }

  publishing {
    singleVariant("release") { withSourcesJar() }
  }
}

dependencies {
  api(project(":chat-core"))

  val composeBom = platform("androidx.compose:compose-bom:2026.05.00")
  implementation(composeBom)
  androidTestImplementation(composeBom)

  api("androidx.compose.foundation:foundation")
  api("androidx.compose.material3:material3")
  implementation("androidx.compose.material:material-icons-extended")
  implementation("androidx.compose.ui:ui-util")
  implementation("androidx.activity:activity-compose:1.13.0")

  testImplementation("junit:junit:4.13.2")
  testImplementation("org.jetbrains.kotlin:kotlin-test-junit:2.3.21")
  androidTestImplementation("androidx.test.ext:junit:1.3.0")
  androidTestImplementation("androidx.test.espresso:espresso-core:3.7.0")
  androidTestImplementation("androidx.compose.ui:ui-test-junit4")
  debugImplementation("androidx.compose.ui:ui-test-manifest")
}

afterEvaluate {
  publishing {
    publications {
      create<MavenPublication>("release") {
        from(components["release"])
        artifactId = "chat-ui-compose"
        pom {
          name.set("Altive Chat UI Compose")
          description.set("AltiveChatのJetpack Compose UIコンポーネント")
          url.set("https://github.com/altive/chat_room_flutter")
          scm {
            url.set("https://github.com/altive/chat_room_flutter")
            connection.set("scm:git:https://github.com/altive/chat_room_flutter.git")
          }
        }
      }
    }
  }
}

publishing {
  repositories {
    maven {
      name = "localBuild"
      url = uri(rootProject.layout.buildDirectory.dir("maven-repository").get().asFile)
    }
    val remoteUrl = providers.gradleProperty("altiveChatMavenUrl")
      .orElse(providers.environmentVariable("ALTIVE_CHAT_MAVEN_URL"))
      .orNull
    if (!remoteUrl.isNullOrBlank()) {
      maven {
        name = "remote"
        url = uri(remoteUrl)
        val remoteUsername = providers.gradleProperty("altiveChatMavenUsername")
          .orElse(providers.environmentVariable("ALTIVE_CHAT_MAVEN_USERNAME"))
          .orNull
        val remotePassword = providers.gradleProperty("altiveChatMavenPassword")
          .orElse(providers.environmentVariable("ALTIVE_CHAT_MAVEN_PASSWORD"))
          .orNull
        if (!remoteUsername.isNullOrBlank() || !remotePassword.isNullOrBlank()) {
          credentials {
            username = remoteUsername
            password = remotePassword
          }
        }
      }
    }
  }
}
