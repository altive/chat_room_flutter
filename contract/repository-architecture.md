# Repository architecture

## 境界

このリポジトリは「チャットUI」という機能単位で管理する。SwiftUI、Flutter、
将来のJetpack Compose実装と、それらが共有する表示契約を同居させる。

認証、Firebase adapter、Analytics、アプリ全体のDesign Systemなど、チャットと
独立してversion管理すべきライブラリは追加しない。

## 現在の配置

```text
.
├── Package.swift                 # Swift Package入口
├── Sources/AltiveChatUI/         # SwiftUI実装
├── Tests/AltiveChatUITests/      # Swift実装のtest
├── contract/                     # プラットフォーム共通契約
├── lib/                          # 既存Flutter package
├── test/                         # Flutter package test
└── example/                      # Flutter example
```

Flutter packageは他アプリから利用中のため、初回再編ではルート配置を維持する。
将来移動する場合は、全利用側をversion付きGit dependencyまたは公開packageへ移行し、
互換期間を設けてから行う。

## 将来のCompose配置

Compose実装へ着手するときだけ、`android/`配下にGradle projectを追加する。空の
projectは先行作成しない。

```text
android/
├── settings.gradle.kts
└── chat-ui-compose/
```

## version

リポジトリ全体をSemVerでversion管理する。プラットフォーム固有の修正でも共通の
patch versionを更新し、contractの破壊的変更ではmajor versionを更新する。
