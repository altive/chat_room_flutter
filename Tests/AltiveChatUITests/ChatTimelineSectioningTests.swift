import Foundation
import Testing

@testable import AltiveChatUI

@Suite("タイムライン区切り")
struct ChatTimelineSectioningTests {
  @Test("先頭と日付変更時だけ日付区切りを開始する")
  func startsNewDay() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let current = Date(timeIntervalSince1970: 86_400 + 43_200)

    #expect(
      ChatTimelineSectioning.startsNewDay(
        currentDate: current,
        previousDate: nil,
        calendar: calendar
      )
    )
    #expect(
      !ChatTimelineSectioning.startsNewDay(
        currentDate: current,
        previousDate: current.addingTimeInterval(-60),
        calendar: calendar
      )
    )
    #expect(
      ChatTimelineSectioning.startsNewDay(
        currentDate: current,
        previousDate: current.addingTimeInterval(-86_400),
        calendar: calendar
      )
    )
  }

  @Test("既読から未読へ変わる境界だけ未読区切りを開始する")
  func startsUnreadSection() {
    #expect(
      ChatTimelineSectioning.startsUnreadSection(
        isUnread: true,
        wasPreviousUnread: false
      )
    )
    #expect(
      !ChatTimelineSectioning.startsUnreadSection(
        isUnread: true,
        wasPreviousUnread: true
      )
    )
    #expect(
      !ChatTimelineSectioning.startsUnreadSection(
        isUnread: false,
        wasPreviousUnread: false
      )
    )
  }
}
