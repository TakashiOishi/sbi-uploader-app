# CLAUDE.md — SBI証券CSVアップローダー

## プロジェクト概要

SBI証券モバイルアプリからCSVファイルをワンタップで個人VPSにアップロードするFlutterアプリ（Android専用）。
ユーザーがSBI証券アプリからCSVを共有すると、本アプリが受け取り、CSVの種類（保有証券 or 配当金）を自動判別して確認ダイアログを表示し、VPSの `/upload/{type}` エンドポイントへマルチパートPOSTで送信する。

## 技術スタック

- **Flutter** 3.x / **Dart** >=3.0.0 <4.0.0
- **Android** minSdk 26
- `receive_sharing_intent` — 他アプリからのファイル共有インテント受信
- `http` — マルチパートアップロード
- `shared_preferences` — VPS URL / APIキーのローカル保存

## ディレクトリ構成

```
lib/
  main.dart              # エントリポイント、ルーティング、共有インテントリスナー
  config.dart            # SharedPreferencesによる設定管理
  upload_service.dart    # CSVタイプ判別 & アップロードロジック
  screens/
    home_screen.dart     # 設定画面（VPS URL / APIキー入力）
    upload_screen.dart   # アップロード確認・進行・結果表示
android/
  app/src/main/AndroidManifest.xml  # インテントフィルター、パーミッション定義
.github/workflows/build.yml         # GitHub Actions CI（APKビルド）
```

## ビルド・実行

```bash
flutter pub get          # 依存パッケージ取得
flutter run              # デバッグ実行
flutter build apk --release  # リリースAPKビルド
```

出力先: `build/app/outputs/flutter-apk/app-release.apk`

## アップロードAPI仕様

- **エンドポイント:** `{VPS_URL}/upload/portfolio` or `/upload/dividend`
- **メソッド:** POST (multipart/form-data)
- **認証ヘッダー:** `X-Api-Key: <api_key>`
- **タイムアウト:** 30秒
- **SSL:** 自己署名証明書を許可（個人VPS向け）

## CSVタイプ判別ロジック

`upload_service.dart` の `detectType(filename)`:
- ファイル名に「配当」「dividend」「分配」→ `CsvType.dividend`
- それ以外（デフォルト）→ `CsvType.portfolio`

ユーザーはアップロード前にUIで手動変更可能。

## 注意事項

- **自己署名証明書:** `HttpClient.badCertificateCallback = (_,_,_) => true` で全証明書を許可。本番運用前には見直すこと。
- **署名設定:** 現状はデバッグ署名でリリースAPKをビルドしている。配布する場合は正式な署名設定が必要。
- **テスト:** `flutter_test` は依存に含まれるがテストコードは未実装。
