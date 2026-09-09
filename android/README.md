# Altive Chat Android

[Altive Chat](https://github.com/altive/altive-chat)のKotlin coreとJetpack Compose UIを、
独立したGradle projectとして提供する。

## 配布方法とMaven coordinates

```text
jp.co.altive.chat:chat-core:<version>
jp.co.altive.chat:chat-ui-compose:<version>
```

`chat-ui-compose`は`chat-core`をAPI dependencyとして公開する。
リポジトリ名は`altive-chat`だが、既存利用との互換性のためMaven coordinatesは変更しない。

ソースをcloneしてローカルMaven成果物を生成するか、composite buildで利用する。
リモートMaven公開先は固定していないため、Maven Central等から取得できることを前提にしない。

## ローカルMaven repositoryへ公開

リポジトリルートで次を実行する。

```bash
make android_publish_local
```

成果物は`android/build/maven-repository`に生成される。
バージョンの既定値は[`gradle.properties`](gradle.properties)の`altiveChatVersion`で管理する。
以下は現在の`1.8.10`をローカルで生成した場合の例で、公開済みのリモート成果物を示すものではない。

利用アプリの`settings.gradle.kts`にローカルMaven repositoryを追加する。
次の相対パスは、利用アプリのGradleルートと`altive-chat/`が隣接する配置を想定している。

```kotlin
dependencyResolutionManagement {
  repositories {
    google()
    mavenCentral()
    maven { url = uri("../altive-chat/android/build/maven-repository") }
  }
}
```

利用アプリのモジュールの`build.gradle.kts`に依存を追加する。
パスとバージョンは、手元の配置と生成した成果物に合わせる。

```kotlin
dependencies {
  implementation("jp.co.altive.chat:chat-ui-compose:1.8.10")
}
```

バージョンを上書きする場合は、`android/`で実行する。

```bash
cd android
./gradlew publishAllPublicationsToLocalBuildRepository \
  -PaltiveChatVersion=1.8.10
```

## リモートMavenへ公開

以下はメンテナー向けの任意の配布手順であり、利用アプリの導入には不要。
公開先はGradle propertyまたは環境変数で指定する。
`ALTIVE_CHAT_MAVEN_URL`などで公開先を設定した場合だけ、リモート公開タスクが登録される。

| Gradle property | 環境変数 | 用途 |
| --- | --- | --- |
| `altiveChatMavenUrl` | `ALTIVE_CHAT_MAVEN_URL` | Maven repository URL |
| `altiveChatMavenUsername` | `ALTIVE_CHAT_MAVEN_USERNAME` | 任意のusername |
| `altiveChatMavenPassword` | `ALTIVE_CHAT_MAVEN_PASSWORD` | 任意のpassword / token |

認証情報を指定しない場合は認証なしで公開を試みる。接続先が認証を要求する場合は設定が必要。
認証情報は環境変数または追跡対象外のユーザー設定で渡し、このリポジトリに保存しない。
実際の公開先・認証・配布対象バージョンを設定したうえで、`android/`で実行する。

```bash
cd android
./gradlew publishAllPublicationsToRemoteRepository \
  -PaltiveChatVersion=1.8.10
```

公開前にリポジトリルートで`make android_verify`を実行し、core test、Compose lint / test、
POM生成を確認する。

## ライセンス

[MIT License](../LICENSE)。両モジュールのPOMにもライセンス名・URLと正規リポジトリURLを含める。
