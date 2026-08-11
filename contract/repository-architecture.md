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
├── Sources/AltiveChatCore/       # Foundationだけに依存する表示契約と状態遷移
├── Sources/AltiveChatUI/         # Coreを利用するSwiftUI実装
├── Tests/AltiveChatCoreTests/    # 純粋な状態遷移のtest
├── Tests/AltiveChatUITests/      # SwiftUI実装のtest
├── contract/                     # プラットフォーム共通契約
├── lib/                          # 既存Flutter package
├── test/                         # Flutter package test
└── example/                      # Flutter example
```

Flutter packageは他アプリから利用中のため、初回再編ではルート配置を維持する。
将来移動する場合は、全利用側をversion付きGit dependencyまたは公開packageへ移行し、
互換期間を設けてから行う。

## Compose配置

Compose実装は、`android/`配下の独立したGradle projectとして管理する。
Flutter exampleが生成する`example/android/`とは依存関係を持たない。

```text
android/
├── settings.gradle.kts
├── chat-core/                    # Composeに依存しない表示契約と状態遷移
└── chat-ui-compose/              # chat-coreを利用するCompose実装
```

ルートを`swift/kotlin/dart`へ一括再編しない。Flutterの既存path dependencyと
Swift Package Managerの標準配置を維持し、破壊的な移動は利用アプリをversion付き
dependencyへ移行して互換期間を設けた後にだけ検討する。

## version

リポジトリ全体をSemVerでversion管理する。プラットフォーム固有の修正でも共通の
patch versionを更新し、contractの破壊的変更ではmajor versionを更新する。
