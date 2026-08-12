import Testing

@testable import AltiveChatUI

struct ChatImageInputConfigurationTests {
  @Test func defaultsToFourSystemPickerImages() {
    let configuration = ChatImageInputConfiguration()

    #expect(configuration.photoLibraryPresentationStyle == .system)
    #expect(configuration.maximumSelectionCount == 4)
  }
}
