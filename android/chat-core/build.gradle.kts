plugins {
  id("org.jetbrains.kotlin.jvm")
  id("maven-publish")
}

kotlin { jvmToolchain(17) }

java { withSourcesJar() }

dependencies {
  testImplementation("org.jetbrains.kotlin:kotlin-test-junit:2.3.21")
}

tasks.test { useJUnit() }

publishing {
  publications {
    create<MavenPublication>("maven") {
      from(components["java"])
      artifactId = "chat-core"
      pom {
        name.set("Altive Chat Core")
        description.set("Altive Chatのプラットフォーム非依存モデルと状態契約")
        url.set("https://github.com/altive/altive-chat")
        licenses {
          license {
            name.set("MIT License")
            url.set("https://opensource.org/license/mit")
            distribution.set("repo")
          }
        }
        scm {
          url.set("https://github.com/altive/altive-chat")
          connection.set("scm:git:https://github.com/altive/altive-chat.git")
        }
      }
    }
  }
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
