# KoKoComboFork

[![iOS CI](https://github.com/cowton0627/KoKoComboFork/actions/workflows/ci.yml/badge.svg)](https://github.com/cowton0627/KoKoComboFork/actions/workflows/ci.yml)

KoKoComboFork 是一個以 UIKit 實作的 KOKO 好友頁展示專案，提供不同好友狀態情境，展示好友清單、好友邀請、搜尋與空狀態畫面。

## Screenshots

<p>
  <img src="Screenshots/scenario-selection.png" width="220" alt="展示情境選擇頁">
  <img src="Screenshots/friends-empty.png" width="220" alt="無好友畫面">
  <img src="Screenshots/friends-list.png" width="220" alt="只有好友列表">
  <img src="Screenshots/friends-invites.png" width="220" alt="好友列表含邀請">
</p>

## 專案簡介

這個 App 以 KOKO 好友頁為主軸，啟動後會先進入展示情境選擇頁，使用者可以切換不同資料狀態，快速查看好友頁在不同情境下的 UI 呈現。

目前支援四種展示情境：

- 無好友畫面
- 只有好友列表
- 好友列表含邀請
- 大量好友邀請（含邀請數量、展開收合與剩餘人數）

## 主要功能

- 展示情境選擇頁
- KOKO 好友主頁 UI
- 好友列表與空狀態切換
- 好友邀請列表顯示與收合
- 大量邀請時最多顯示兩列，並提示剩餘邀請數
- 接受或拒絕邀請後，重新整理仍保留本次使用狀態
- 好友搜尋與即時篩選
- 下拉重新整理好友資料
- Demo 範圍外的入口會顯示明確提示，不會點擊後無反應
- 自訂 Tab Bar 外觀
- 情境頁與主頁之間可返回切換，方便展示
- VoiceOver 動態操作名稱與 UI test identifiers
- 主要好友與邀請文字支援 Dynamic Type
- 主要自訂元件使用語意色，支援 Light / Dark Mode

## 技術內容

- Swift 5
- UIKit
- Storyboard / XIB
- MVVM 基本分層
- URLSession async/await API 請求
- 可注入 URLSession 的網路層
- 自訂 View、Button、Segmented Control、Tab Bar
- XCTest 單元測試

## Architecture

專案採用 UIKit + MVVM 的分層方向：

- `Controller`：負責 UIKit lifecycle、navigation、binding ViewModel output、套用畫面狀態
- `ViewModel`：負責資料請求、好友資料合併、搜尋篩選、cell display model、部分畫面狀態
- `Network`：封裝 API endpoint、request、response decode 與 service protocol
- `Model`：放置 API response 與 domain model
- `View`：放置 storyboard、xib、custom view 與 table view cell

目前 ViewModel 透過 `UserServicing` 注入資料服務，方便使用 mock service 撰寫單元測試。好友列表 cell 也改由 `FriendCellViewModel` 提供顯示資料，降低 cell 對 domain model 與上層 ViewModel 的耦合。

Network 層以 `FriendDTO` 接收 API 的 `status: Int`、`isTop: String` 與兩種日期字串格式，進入 App 前統一轉換成 `FriendStatus`、`Bool` 與 `Date?`。ViewModel 與 View 不需要知道後端的 magic number 或字串編碼規則。

畫面綁定採用自製的 `Boxed<T>` property wrapper（`Helper/Boxed.swift`，約 25 行的 minimal observable），刻意不引入 RxSwift 或 Combine，維持零第三方相依。Controller 端使用 `viewModel.$state.bind { ... }` 訂閱變化。

好友資料、搜尋結果、邀請與載入狀態統一由 `FriendsScreenState` 一次發射；header 高度、邀請列表高度與 segmented 顯隱則由 `FriendsOverviewState` 管理，避免相關欄位分批更新造成暫態不一致。兩個 ViewModel 都標記為 `@MainActor`，讓 UI state 的讀寫具有明確的 concurrency 邊界。

設計選擇的完整理由請見 [DECISIONS.md](./DECISIONS.md)。

## 資料來源

專案使用自己維護的 GitHub Pages JSON 作為展示資料；測試內容源自公開面試題資料：

- `man.json`
- `friend1.json`
- `friend2.json`
- `friend3.json`
- `friend4.json`
- `friend5.json`

API root endpoint：

```text
https://cowton-apis.github.io/koko/
```

## 專案結構

```text
KoKoComboFork/
├── Controller/
│   ├── Friend/
│   ├── Main/
│   ├── MainTabBarController/
│   └── Scenario/
├── Model/
├── Network/
├── View/
│   ├── Customised/
│   └── TableViewCell/
├── ViewModel/
├── Extension/
├── Helper/
└── Assets.xcassets/
```

## 執行環境

- Xcode 16 或以上
- iOS 16.0 或以上
- Swift 5

## 如何執行

1. 開啟 `KoKoComboFork.xcodeproj`
2. 選擇 iOS Simulator
3. 執行 `KoKoComboFork` scheme

建議使用較新的 iPhone Simulator，例如：

```text
iPhone 17 Pro Max
```

> Signing 設定：repo 不保存個人 Team ID，bundle identifier 使用中性的
> `com.example.*`，方便 clone 後直接在 Simulator 跑。若要長期使用真機，
> 請將 `Config/Signing.local.xcconfig.example` 複製為
> `Config/Signing.local.xcconfig`，填入自己的 `DEVELOPMENT_TEAM`。local 檔已被
> gitignore，設定一次後不必每次重新選 Team。

## 測試

可以透過 Xcode Test，或使用指令執行：

```bash
xcodebuild test \
  -project KoKoComboFork.xcodeproj \
  -scheme KoKoComboFork \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
```

如果本機沒有這個 Simulator，可先用
`xcrun simctl list devices available` 查詢並替換裝置名稱。

目前測試涵蓋：

- 好友清單情境資料載入
- 好友資料合併邏輯
- 搜尋篩選邏輯
- 邀請接受與拒絕後的列表狀態，以及重新整理後的 session 一致性
- 畫面狀態與輕量 observable 行為
- HTTP success、非 2xx、無效 JSON 與網路中斷
- 大量邀請的展開、收合、接受與數量更新 UI smoke test

目前共有 40 個自動化測試（39 個 unit/integration tests＋1 個 XCUITest）。

GitHub Actions 會在每次 push 到 `main` 或建立 pull request 時，動態選擇可用的
iPhone Simulator 並執行完整測試，不依賴固定的 Simulator 型號或 OS patch 版本。

## Disclaimer

本專案為個人 iOS 開發練習作品，僅用於學習 UIKit / MVVM 分層與單元測試。

- 「KOKO」為國泰世華商業銀行旗下品牌，本專案與其官方並無任何關聯，也非該品牌之官方產品。
- 專案中的 UI 佈局、icon、配色僅為仿照原 App 介面進行 UI 練習，所有商標、品牌名稱與設計版權皆屬原權利人所有。
- 展示資料 (`man.json`、`friend1~5.json`) 以公開面試題測資為基礎整理，透過自行維護的 GitHub Pages mock API 提供，並非真實使用者資料。
- 若任何權利人認為內容有侵權疑慮，請透過此 repo 的 [issues](https://github.com/cowton0627/KoKoComboFork/issues) 反映，我會立即下架對應內容。

## Privacy

本 App 不會蒐集任何個人資料，也不整合分析 SDK；執行期間只會向 GitHub
Pages 讀取公開的展示用 JSON。完整說明請見 [PRIVACY.md](./PRIVACY.md)。

## License

本專案以 [MIT License](./LICENSE) 釋出。第三方相依與授權彙整請見 [THIRD_PARTY_LICENSES.md](./THIRD_PARTY_LICENSES.md)（目前無第三方相依）。
