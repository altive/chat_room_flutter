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
      name: "AltiveChatUI",
      targets: ["AltiveChatUI"]
    )
  ],
  targets: [
    .target(
      name: "AltiveChatUI",
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "AltiveChatUITests",
      dependencies: ["AltiveChatUI"]
    ),
  ]
)
