# AltiveChat Android

AltiveChatのKotlin coreとJetpack Compose UIを、独立したGradle projectとして提供する。

## Maven coordinates

```text
jp.co.altive.chat:chat-core:<version>
jp.co.altive.chat:chat-ui-compose:<version>
```

`chat-ui-compose` は `chat-core` をAPI dependencyとして公開する。

## ローカルMaven repositoryへ公開

repository rootで次を実行する。

```bash
make android_publish_local
```

成果物は `android/build/maven-repository` に生成される。consumer側ではMaven
repository URLをこのdirectoryへ向け、次のように依存する。

```kotlin
dependencies {
  implementation("jp.co.altive.chat:chat-ui-compose:0.1.0-SNAPSHOT")
}
```

versionはGradle propertyで上書きできる。

```bash
./gradlew publishAllPublicationsToLocalBuildRepository \
  -PaltiveChatVersion=0.1.0
```

## Remote Mavenへ公開

公開先はGradle propertyまたは環境変数で指定する。

| Gradle property | 環境変数 | 用途 |
| --- | --- | --- |
| `altiveChatMavenUrl` | `ALTIVE_CHAT_MAVEN_URL` | Maven repository URL |
| `altiveChatMavenUsername` | `ALTIVE_CHAT_MAVEN_USERNAME` | 任意のusername |
| `altiveChatMavenPassword` | `ALTIVE_CHAT_MAVEN_PASSWORD` | 任意のpassword / token |

認証情報を指定しなければ、認証不要のMaven repositoryとして公開する。

```bash
./gradlew publishAllPublicationsToRemoteRepository \
  -PaltiveChatVersion=0.1.0
```

公開前に `make android_verify` を実行し、core test、Compose lint / test、POM生成を
確認する。
