.PHONY: flutter_verify swift_format_lint swift_ios_build swift_test swift_verify verify

verify: flutter_verify swift_verify

flutter_verify:
	flutter pub get
	flutter analyze
	flutter test

swift_verify: swift_format_lint swift_test swift_ios_build

swift_format_lint:
	xcrun swift-format lint --recursive --strict Package.swift Sources Tests

swift_test:
	swift test

swift_ios_build:
	xcodebuild -scheme AltiveChat-Package -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/altive-chat-derived CODE_SIGNING_ALLOWED=NO build
