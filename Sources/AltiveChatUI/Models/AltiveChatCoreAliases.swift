import AltiveChatCore

/// `AltiveChatUI`だけをimportする既存利用側向けのユーザー型。
public typealias ChatUser = AltiveChatCore.ChatUser

/// `AltiveChatUI`だけをimportする既存利用側向けのメッセージ内容型。
public typealias ChatMessageContent = AltiveChatCore.ChatMessageContent

/// `AltiveChatUI`だけをimportする既存利用側向けの送信状態型。
public typealias ChatMessageDeliveryState = AltiveChatCore.ChatMessageDeliveryState

/// 送信状態の純粋な遷移。
public typealias ChatDeliveryStateMachine = AltiveChatCore.ChatDeliveryStateMachine

/// `AltiveChatUI`だけをimportする既存利用側向けのメッセージ型。
public typealias ChatMessage = AltiveChatCore.ChatMessage

/// チャット画像の読み込み元。
public typealias ChatImageResource = AltiveChatCore.ChatImageResource

/// 画像メッセージへ表示する画像。
public typealias ChatImage = AltiveChatCore.ChatImage

/// 送信前に入力欄で保持する画像。
public typealias ChatImageDraft = AltiveChatCore.ChatImageDraft

/// テキストと画像をまとめた送信要求。
public typealias ChatComposerSubmission = AltiveChatCore.ChatComposerSubmission

/// 解決済みのWebリンクプレビュー表示値。
public typealias ChatLinkPreview = AltiveChatCore.ChatLinkPreview

/// リンクプレビュー画像のopaqueな参照と寸法。
public typealias ChatLinkPreviewImage = AltiveChatCore.ChatLinkPreviewImage

/// テキスト内の先頭HTTP(S) URLを選ぶparser。
public typealias ChatWebURLParser = AltiveChatCore.ChatWebURLParser

/// チャット入力の方針。
public typealias ChatDraftPolicy = AltiveChatCore.ChatDraftPolicy

/// チャット入力長を数える単位。
public typealias ChatDraftLengthUnit = AltiveChatCore.ChatDraftLengthUnit

/// リアクションの表示値。
public typealias ChatReaction = AltiveChatCore.ChatReaction

/// リアクション件数の表示値。
public typealias ChatReactionCount = AltiveChatCore.ChatReactionCount

/// 競合を壊さない楽観的更新値。
public typealias ChatOptimisticMutation<Value> = AltiveChatCore.ChatOptimisticMutation<Value>
where Value: Equatable, Value: Sendable

/// 最近利用した値の更新処理。
public typealias ChatRecentItems = AltiveChatCore.ChatRecentItems

/// ステッカー参照の共通契約。
public typealias ChatStickerReference = AltiveChatCore.ChatStickerReference

/// システムイベントの共通表示値。
public typealias ChatSystemEventItem = AltiveChatCore.ChatSystemEventItem
