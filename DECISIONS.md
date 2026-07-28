# DECISIONS

這份文件記錄本專案中比較需要說明的設計決策與背後理由。

- 「怎麼用 / 怎麼操作」 → 看 [README.md](./README.md)
- 「為什麼這樣選 / 放棄過哪些方案」 → 看這份

---

## 採用 MVVM，不採用 MVC / VIPER / TCA

KOKO 好友頁的畫面狀態組合多（搜尋中 / 載入中 / 有邀請 / 無好友 / 邀請列表收合展開），純 MVC 的 Controller 容易膨脹；VIPER / Clean Architecture 對這種單頁 demo 過於繁重；TCA / Composable Architecture 學習曲線高、相依重，與「零第三方」原則衝突。

MVVM 剛好把畫面狀態邏輯抽進 ViewModel，搭配 protocol 注入就能用 `XCTest` 單測（目前涵蓋好友資料合併與搜尋篩選）。

---

## 用自製 `Boxed<T>` 取代 RxSwift / Combine 做畫面綁定

`Helper/Boxed.swift` 是一個約 25 行的 `@propertyWrapper`：`wrappedValue` 的 `didSet` 觸發 listeners、`bind` 訂閱時立即回 callback 一次（行為等效於 RxSwift 的 `BehaviorRelay`）。

**選擇理由**

- **零第三方相依**：不想為了 binding 多拉 RxSwift / RxCocoa 整套。
- **API 簡單**：`@Boxed`、`$value`、`bind { }` 三個 API 就夠用，新 contributor / reviewer 看完原始碼就懂全部。
- **vs Combine**：iOS 16 部署門檻下其實可以用 Combine，但 Combine + UIKit binding 仍需 `assign(to:on:)` + `AnyCancellable` 管理，相較之下 `Boxed` 的 API 更直覺、零相依。

**代價**

沒有 throttle / debounce / combineLatest 這類 operator。例如搜尋若要 debounce 得自寫；目前 demo 規模未需要。未來若需要 operator 組合，會考慮一次性遷到 Combine（API 哲學最接近）。

---

## Cell 透過 `FriendCellViewModel` 顯示，不直接吃 `Friend`

`FriendCellViewModel` 是 cell 專用的扁平 struct（`name`、`isTop`、`showsInvitingButton`、`showsDetailButton`），由 `FriendsViewModel.cellViewModel(at:)` 算好回傳。

**理由**

- Cell 不應該認識 `status == 1` 代表邀請中、`isTop == "1"` 是字串對照這種 domain 規則，否則同類判斷會散在多處。
- 顯示用旗標一次在 ViewModel 算好，cell 只負責 render。
- 未來 domain model 改欄位名或型別（例如 `isTop: String` → `Bool`）時 cell 不用改。

---

## API DTO 與 Domain Model 分離

GitHub Pages JSON 使用 `status: Int`、`isTop: String`，日期也同時存在
`yyyyMMdd` 與 `yyyy/MM/dd`。Network 層先 decode 成 `FriendDTO`，再轉成
App 內部的 `Friend`：

- `status` → `FriendStatus`
- `isTop` → `isPinned: Bool`
- `updateDate` → `updatedAt: Date?`

未知 status 會保留為 `.unknown(rawValue)`，方便診斷資料契約變化，而不是默默當成某個既有狀態。如此 magic number、格式解析與後端命名都不會散落到 ViewModel 或 View。

---

## 用 `UserServicing` protocol 注入 service

ViewModel 透過 protocol 收 service：

```swift
init(userService: UserServicing = UserService.shared)
```

Production 端用 default 拿單例、測試端傳入 `MockUserService`。

**理由**

- Swift 沒有 reflection-based mocking 框架（OCMock 那種），protocol 注入是最自然的測試解法。
- Default argument 讓 production 呼叫端不用每次手動傳。
- `XCTest` 的 mock service 直接實作 protocol 就能控制不同情境回傳，不需要動到 production code。

---

## `URLSession` 由 `APIService` 注入

Production 預設使用 `URLSession.shared`，測試則注入設定了自訂
`URLProtocol` 的 ephemeral session。網路測試因此不會真的呼叫 GitHub Pages，
也能精確模擬：

- 200 response 與 JSON decode
- 非 2xx HTTP status
- 無效 JSON
- transport failure

ViewModel 測試透過 `UserServicing` mock 驗證商業邏輯，APIService 測試透過
URLSession 注入驗證 HTTP 行為，兩層各自負責不同範圍。

---

## 不引入任何第三方相依

沒有 SPM、CocoaPods、Carthage。執行階段只依賴 Apple 原生框架（`UIKit`、`Foundation`、`XCTest`）。

**理由**

- Portfolio / 練習用途，相依越少 reviewer clone 後越好直接 build。
- 沒有第三方 license 兼容性問題（搭配 [THIRD_PARTY_LICENSES.md](./THIRD_PARTY_LICENSES.md)）。
- 沒有第三方 SDK 蒐集資料的可能（搭配 [PRIVACY.md](./PRIVACY.md) 的「零蒐集」主張）。
- Reactive binding、HTTP 等需求原生都有解法。

---

## 用 `FriendsOverviewState` struct 包多個 UI 狀態

把會一起變化的多個 UI 屬性（header 高度、邀請列表高度、segmented 顯隱）包進一個 struct，透過單一 `@Boxed` 發射。

**理由**

- 拆成多個獨立 `@Boxed Bool / Double` 時，Controller 端要收 3+ 個 bind block，且容易出現「高度變了但 segmented 還沒變」的暫態不同步。
- 包成 struct 後每次發整包，Controller 一個 `bind { state in ... }` 就 atomic 套用所有欄位。
- struct 化的 state 同時相容未來換成 Combine 的 `@Published` 或 TCA 的 `State`。

---

## 好友頁使用單一 `FriendsScreenState`

好友原始資料、搜尋結果、邀請列表與 loading/error 狀態放在同一個
`FriendsScreenState`，Controller 只訂閱一次。

**理由**

- 一次資料更新只發出一份完整 state，避免 table 已更新但邀請高度仍是舊值。
- 接受邀請時，主列表、搜尋結果與邀請列表會原子更新。
- ViewModel 標記為 `@MainActor`，UI state 不再混用手動 lock 與 main queue dispatch。
- 情境一的兩份好友 API 使用 `async let` 並行取得，合併規則仍集中在 ViewModel。

---

## 大量邀請最多顯示兩列

邀請區不隨資料筆數無限增高。展開時最多顯示兩列，收合時顯示一列，
其餘以「還有 N 位邀請」提示，並允許邀請區內捲動。

展開／收合改由具名按鈕操作，不再以點擊邀請 cell 觸發，避免與選取好友
或接受／拒絕操作產生語意衝突。邀請數降為一時隱藏切換按鈕，降為零時
整個邀請區收起。

---

## 邀請操作在目前 App session 內維持一致

GitHub Pages 展示 API 是唯讀靜態 JSON，無法真正寫回接受或拒絕結果。因此
`FriendsViewModel` 會記錄本次 App session 已接受與已拒絕的 fid，重新整理取得
原始資料後再套用使用者操作：

- 已接受的邀請維持好友狀態，不會重新出現在邀請區。
- 已拒絕的邀請維持隱藏，但仍保留在下方主列表。

這避免 pull-to-refresh 讓剛完成的操作立即「復活」，同時不假裝 demo 已經具備
後端寫入能力。App 完全關閉後狀態會重設，符合靜態資料展示的界線。

---

## Accessibility 使用動態操作名稱

接受與拒絕按鈕的 VoiceOver 名稱包含好友姓名，例如「接受黃靖僑的好友邀請」，
避免多個圖示按鈕都只被念成相同名稱。情境、搜尋、列表、邀請數量與展開按鈕
也提供穩定的 accessibility identifier，供 UI test 使用。

主要好友與邀請文字採用 Dynamic Type font，展開按鈕同時提供
「已展開／已收合」value 與下一步操作 hint。

---

## Storyboard 主畫面 + XIB cell

主畫面（`Main.storyboard`、`Friend.storyboard`、`Scenario.storyboard`）用 Storyboard，可重用元件（如 cell）用 XIB。

**理由**

- 練習目標包含 Interface Builder 操作（segue、Auto Layout 視覺編輯）。
- 對「仿照既有 App 介面」這種任務，IB 比純 code-based UI 開發快很多。
- 對 reviewer 而言，IB 比讀 SnapKit / NSLayoutAnchor 程式碼更容易追畫面結構。

**已知代價**

- Storyboard 的 segue / `customClass` 是 magic string，不像純 code UI 能編譯期防錯。
- Multi-developer 同時編輯 storyboard 容易產生難 merge 的 XML 衝突；單人專案不是問題。

---

## Known Limitations

以下是專案目前**已知但尚未處理**的缺陷與限制。記在這裡是為了誠實揭露現狀，並標示未來迭代時優先處理的方向。

### UX / 功能面

- **部分按鈕仍是展示用途**。轉帳、掃碼、設定 KOKO ID、新增好友與好友詳細
  功能不在本 demo 範圍；點擊時會顯示「展示版尚未提供」提示，不會導向完整流程。
- **邀請操作只保留於目前 App session**。展示 API 是唯讀 JSON，App 完全關閉
  後會回到 API 原始狀態；正式產品應由後端保存。
- **使用者資料載入失敗時沒有獨立錯誤提示**。好友列表已有 loading、錯誤提示與重試；頁首使用者資料失敗時則維持空白，避免同頁同時出現兩個錯誤彈窗。後續可將兩者整合成單一 screen state。

### 程式碼結構

- **畫面狀態分散在兩個 ViewModel**。`UserViewModel` 管理使用者資料與頁首狀態，`FriendsViewModel` 管理列表資料；兩者目前由 `FriendsViewController` 協調。若畫面持續擴張，可再引入統一的 screen-level state。
- **尚未建立統一 logger**。目前 production code 不輸出 debug 訊息；若未來需要診斷資訊，應以隱私安全的 `OSLog` 分類記錄。

### 工程實踐

- **沒有 SwiftLint / SwiftFormat 設定**。風格一致性目前只靠人眼。
- **Dark Mode 尚未完成全流程人工稽核**。自訂卡片、分頁與 Tab Bar 已改用語意色，
  情境選擇頁也已在深色 Simulator 實際檢查；各好友情境與最大字級組合仍需逐頁檢查。
- **尚未完成全 App 的 Accessibility audit**。好友與邀請主要流程已有動態 VoiceOver label、identifier 與部分 Dynamic Type；自訂 Tab Bar、最大字級版面及完整 VoiceOver 焦點順序仍需實機檢查。

### 部署 / Signing

- `project.pbxproj` 不保存個人 Team ID。App target 的 Debug／Release configuration
  共同讀取 `Config/Signing.xcconfig`，再以 optional include 載入 gitignored 的
  `Config/Signing.local.xcconfig`。本機真機簽署設定可持續保留，公開 repo 與
  CI 則不會取得個人 Team ID。

### Reactive binding

- 搜尋 debounce 與未來潛在的 Combine 遷移，理由與權衡記於上方「用自製 `Boxed<T>` 取代 RxSwift / Combine」段。
