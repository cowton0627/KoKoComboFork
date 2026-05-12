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

- **沒有使用者可見的 error UI**。`APIService` 失敗時只 `print(error)`，畫面不會出 alert / toast，使用者只會看到永久的等待狀態。最低限度應該補一個 `UIAlertController` 彈窗 + 「重試」按鈕。
- **沒有 loading indicator**。fetch 期間畫面靜止無回饋，使用者無法判斷是斷網還是還在跑。
- **主好友頁（`FriendsViewController`）沒有 pull-to-refresh**。`UIRefreshControl` 目前只接在 `FriendsDetailViewController`，README 宣稱有的「下拉重新整理」在主畫面其實沒做。
- **`UserViewModel.fetchFriendsData()` 是 hardcoded 假資料**（寫死兩筆假人名），沒有實際呼叫 service。是下方「程式碼結構」議題的一部分。

### 程式碼結構

- **兩個 ViewModel 對「friend list」職責切分不清**。`FriendsViewModel` 透過 `UserServicing` 真的 fetch；`UserViewModel` 自己 hardcode 一份。應該整併或明確分工（例如 `UserViewModel` 只管畫面狀態與使用者資料、`FriendsViewModel` 管列表資料）。
- **約 200+ 行注解掉的 dead code 散落多處**（`View/Customised/InvitationListView.swift`、`View/Customised/CustomSegmentedView.swift`、`Network/APIService.swift` 的 alternate `send` 實作、`ViewModel/UserViewModel.swift` 早期版本等）。屬迭代過程留下的痕跡，應該清掉。
- **~30 處 debug `print()`** 散在 ViewModel / Controller / APIService。沒走 `OSLog` 或統一 logger，release build 也會印。

### 工程實踐

- **沒有 CI**。`.github/workflows/` 不存在，PR 不會自動跑 `xcodebuild test`，全靠手動執行。
- **沒有 SwiftLint / SwiftFormat 設定**。風格一致性目前只靠人眼。
- **沒做 Dark Mode 適配**。沒有任何 `traitCollection` / `overrideUserInterfaceStyle` 處理，深色模式下顏色可能不正確。
- **沒有 accessibility 標籤**。`accessibilityLabel` / `accessibilityIdentifier` 0 hits，VoiceOver 體驗差。

### 部署 / Signing

- **`DEVELOPMENT_TEAM` 仍寫在 `project.pbxproj`**（目前為空字串）。若未來在 Xcode 內選了開發者 team，Xcode 會把 team ID 寫回 pbxproj，再次 commit 就可能洩漏到公開 history。**未來會做的**：把 signing 設定拉出至 gitignored 的 `Config/Signing.local.xcconfig`，pbxproj 永遠不持 team / bundle id。

### Reactive binding

- 搜尋 debounce 與未來潛在的 Combine 遷移，理由與權衡記於上方「用自製 `Boxed<T>` 取代 RxSwift / Combine」段。
