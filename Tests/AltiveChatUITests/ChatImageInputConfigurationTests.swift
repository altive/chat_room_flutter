import Testing

@testable import AltiveChatUI

struct ChatImageInputConfigurationTests {
  @Test func defaultsToFourSystemPickerImagesWithInlineExpansionAvailable() {
    let configuration = ChatImageInputConfiguration()

    #expect(configuration.photoLibraryPresentationStyle == .system)
    #expect(configuration.maximumSelectionCount == 4)
    #expect(configuration.allowsInlineExpansion)
  }
}
