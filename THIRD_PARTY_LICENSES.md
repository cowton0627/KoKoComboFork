# Third-Party Licenses

本專案**目前不含任何第三方相依套件**：

- 無 Swift Package Manager 相依（`Package.swift`、`Package.resolved` 皆不存在）
- 無 CocoaPods（`Podfile`、`Podfile.lock`、`Pods/` 皆不存在）
- 無 Carthage（`Cartfile`、`Cartfile.resolved`、`Carthage/` 皆不存在）

執行階段僅使用 Apple 平台原生框架：

- `UIKit`
- `Foundation`
- `XCTest`（測試用）

以上框架由 Apple 提供，其授權條款隨 Xcode / iOS SDK 一同提供。

若日後加入任何第三方相依，請將對應的套件名稱、版本、原始碼來源與授權條款列於本檔。
