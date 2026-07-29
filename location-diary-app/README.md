# 位置情報日記自動生成アプリ (location-diary-app)

アップロードされた仕様書「位置情報日記自動生成アプリ 仕様書」に基づく Flutter アプリ。
Android を主対象。1日の移動記録を自動収集し、Claude API で自然な日本語の日記を生成する。

このフォルダーはリポジトリ直下の `thinking-map`(React製の別アプリ) とは無関係の、独立した
Flutter プロジェクトです。

## フェーズ1(このコミット)で実装した範囲

- プロジェクト雛形一式 (`flutter create` 済み、Android向け)
- データ層 (`lib/data/`): SQLite (`sqflite`) によるモデル・スキーマ・リポジトリ
  (`LocationLog`, `VisitedPlace`, `DiaryEntry`, `PlaceAlias`)
- 滞在・移動区間検出ロジック (`lib/domain/stay_detection.dart`):
  プラットフォーム非依存の純粋な Dart アルゴリズム。`flutter test` で検証済み
- サービス層 (`lib/services/`)
  - `LocationService` / `BackgroundLocationService`: 位置情報取得・バックグラウンド収集の配線
  - `GeocodingService` (既定実装: OpenStreetMap Nominatim, APIキー不要)
  - `DiaryGenerationService` (Claude API 実装 + APIキー未設定時のモック実装)
  - `ApiKeyStorage`: Claude APIキーを `flutter_secure_storage` に安全に保管
- 画面 (`lib/screens/`): ホーム、日記一覧、日記詳細(手動編集対応)、場所エイリアス設定、設定
- Riverpod (`flutter_riverpod`) による状態管理・DI (`lib/providers/`)

## このセッション(クラウド開発コンテナ)での検証範囲

このアプリは開発用クラウドコンテナ内で作成されました。コンテナには Android SDK・エミュレータ・
実機が無いため、以下のみ検証済みです。

- `flutter analyze` (静的解析、warning/error 0件)
- `flutter test` (滞在検出ロジックのユニットテスト5件 + 起動スモークテスト1件、全て成功)

以下は **実機での検証が必要** です(このセッションでは未検証)。

- バックグラウンドでの位置情報自動収集 (`flutter_background_service` の実際の動作)
- Android のフォアグラウンド通知・権限ダイアログ
- 実際の GPS 精度・バッテリー消費
- Claude API / Nominatim への実際のネットワーク呼び出し (Claude APIキーが必要)

## セットアップ (実機/エミュレータで動かす場合)

```bash
cd location-diary-app
flutter pub get
flutter run
```

設定画面から Claude APIキーを登録すると、実際の日記生成が有効になります(未設定の間は
仮の日記文が表示されます)。

## フェーズ2以降のTODO(未着手)

- Activity Recognition API による移動手段推定の高精度化(現状は取得時に指定した値のみ)
- 日記生成トリガー時刻・収集間隔設定の永続化(現在は画面上の一時状態のみ)
- 過去の Google タイムライン JSON の一括インポート
- Notion / Google Docs 等へのエクスポート連携
- 写真連携、週次・月次サマリー
- iOS 対応の検証(プロジェクト雛形はあるが未検証)
