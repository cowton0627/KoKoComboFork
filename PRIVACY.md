# Privacy

KoKoComboFork 是個人 iOS 練習作品，僅作為 UI / 資料狀態展示用途，**不會蒐集、儲存或上傳任何個人資料**。

## 資料蒐集

- 本 App 不要求登入，也不要求授權任何系統權限（相機、位置、通訊錄、通知、麥克風等）。
- 本 App 未整合任何分析 (analytics) 或第三方 SDK，例如 Firebase、Crashlytics、AppsFlyer、Sentry 等。
- 本 App 不寫入任何雲端服務或本機持久化儲存，所有展示資料僅在 App 執行期間存於記憶體 (RAM)。

## 網路請求

App 在執行期間僅會對下列公開端點發送 `GET` 請求，目的是讀取展示用的 JSON 假資料：

- `https://cowton-apis.github.io/koko/`（自行維護的 GitHub Pages mock API）

請求不包含任何使用者識別資訊（無 token、無 user id、無 device id），且 App 不會將請求結果記錄成 log 或回傳給任何第三方。

## 聯絡

若對隱私處理有疑問，請透過此 repo 的 [issues](https://github.com/cowton0627/KoKoComboFork/issues) 回報。
