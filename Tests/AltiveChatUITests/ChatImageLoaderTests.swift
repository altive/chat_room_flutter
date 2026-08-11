import Foundation
import Testing

@testable import AltiveChatUI

struct ChatImageLoaderTests {
  @Test func standardLoaderReadsLocalFile() async throws {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("bin")
    let expectedData = Data([0x01, 0x02, 0x03])
    try expectedData.write(to: url)
    defer { try? FileManager.default.removeItem(at: url) }

    let loadedData = try await ChatImageLoader.standard.data(for: .localFile(url))

    #expect(loadedData == expectedData)
  }

  @Test func customLoaderReceivesResource() async throws {
    let url = try #require(URL(string: "https://example.com/image.jpg"))
    let loader = ChatImageLoader { resource in
      #expect(resource == .remote(url))
      return Data([0x04])
    }

    #expect(try await loader.data(for: .remote(url)) == Data([0x04]))
  }
}
