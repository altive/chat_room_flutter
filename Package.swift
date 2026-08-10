// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "AltiveChat",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "AltiveChatCore",
      targets: ["AltiveChatCore"]
    ),
    .library(
      name: "AltiveChatUI",
      targets: ["AltiveChatUI"]
    ),
  ],
  targets: [
    .target(
      name: "AltiveChatCore"
    ),
    .target(
      name: "AltiveChatUI",
      dependencies: ["AltiveChatCore"],
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "AltiveChatCoreTests",
      dependencies: ["AltiveChatCore"]
    ),
    .testTarget(
      name: "AltiveChatUITests",
      dependencies: ["AltiveChatUI"]
    ),
  ]
)
