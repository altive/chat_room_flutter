import Testing

@testable import AltiveChatUI

struct ChatImageInputConfigurationTests {
  @Test func defaultsToFourPickerImages() {
    let configuration = ChatImageInputConfiguration()

    #expect(configuration.maximumSelectionCount == 4)
  }
}
