package jp.co.altive.chat

import java.time.LocalDateTime
import java.time.ZoneId
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ChatTimelineSectioningTest {
  private val zone = ZoneId.of("Asia/Tokyo")

  @Test
  fun `先頭と日付変更時だけ日付区切りを開始する`() {
    val current = epoch(2026, 8, 25, 0, 1)
    assertTrue(ChatTimelineSectioning.startsNewDay(current, null, zone))
    assertFalse(ChatTimelineSectioning.startsNewDay(current, epoch(2026, 8, 25, 0, 0), zone))
    assertTrue(ChatTimelineSectioning.startsNewDay(current, epoch(2026, 8, 24, 23, 59), zone))
  }

  @Test
  fun `既読から未読へ変わる境界だけ未読区切りを開始する`() {
    assertTrue(ChatTimelineSectioning.startsUnreadSection(isUnread = true, wasPreviousUnread = false))
    assertFalse(ChatTimelineSectioning.startsUnreadSection(isUnread = true, wasPreviousUnread = true))
    assertFalse(ChatTimelineSectioning.startsUnreadSection(isUnread = false, wasPreviousUnread = false))
  }

  private fun epoch(year: Int, month: Int, day: Int, hour: Int, minute: Int): Long =
    LocalDateTime.of(year, month, day, hour, minute).atZone(zone).toInstant().toEpochMilli()
}
