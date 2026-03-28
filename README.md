# SBI証券CSVアップローダー

SBI証券モバイルアプリからCSVファイルをワンタップで個人VPSにアップロードするAndroidアプリです。

## 機能

- SBI証券アプリから「共有」でCSVを受け取る
- CSVの種類（保有証券 / 配当金・分配金）を自動判別
- アップロード前に種類の確認・変更が可能
- VPS URLとAPIキーをアプリ内に保存して繰り返し利用

## 必要な環境

- Android 8.0 (API 26) 以上
- 個人VPS（アップロード先）

## セットアップ

### 1. アプリのインストール

GitHub ActionsでビルドされたAPKをダウンロードしてインストールするか、手元でビルドします。

```bash
flutter pub get
flutter build apk --release
```

### 2. VPS側の準備

以下のエンドポイントを用意してください。

| エンドポイント | 説明 |
|---|---|
| `POST /upload/portfolio` | 保有証券CSV |
| `POST /upload/dividend` | 配当金・分配金CSV |

- リクエスト形式: `multipart/form-data`
- 認証: `X-Api-Key` ヘッダー

### 3. アプリの初期設定

アプリを起動し、設定画面でVPS URLとAPIキーを入力して保存します。

```
VPS URL  : https://YOUR_VPS_IP
API Key  : your-secret-api-key
```

## 使い方

1. SBI証券アプリでCSVをダウンロード
2. 「共有」ボタンから **SBI Uploader** を選択
3. CSVの種類を確認（必要なら変更）
4. 「アップロード」をタップ

## 開発

```bash
# 依存パッケージ取得
flutter pub get

# デバッグ実行
flutter run

# リリースビルド
flutter build apk --release
```

### 主要ファイル

| ファイル | 役割 |
|---|---|
| `lib/main.dart` | エントリポイント、共有インテント処理 |
| `lib/config.dart` | 設定の保存・読み込み |
| `lib/upload_service.dart` | CSVタイプ判別 & アップロード |
| `lib/screens/home_screen.dart` | 設定画面 |
| `lib/screens/upload_screen.dart` | アップロード確認・実行画面 |

## CI/CD

`main` ブランチへのプッシュ時にGitHub ActionsでリリースAPKが自動ビルドされます。
ビルド成果物は30日間保持されます。

## 注意事項

- 自己署名証明書を使用したVPSに接続可能ですが、本番環境では正規の証明書を推奨します
- APIキーはデバイスのSharedPreferencesに保存されます（クラウド同期なし）
