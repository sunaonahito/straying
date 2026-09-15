# Module Design

## RNF.config

役割

システム全体の設定を管理する。

---

## RNF.player

役割

プレイヤーID
セッション
プレイ開始時間

を管理する。

---

## RNF.logger

役割

イベントログ

回答ログ

を管理する。

---

## RNF.storage

役割

ローカル保存

Google Spreadsheet送信

---

## RNF.tyrano

役割

ティラノスクリプトとの橋渡し。

---

## RNF.utils

役割

共通関数

## 機能領域の分離

RNFでは、研究向け機能とゲーム向け機能を分離する。

### Research領域

- Event Log
- Answer Log
- 回答時間
- 途中離脱記録
- 外部データ送信

### Game領域

- ゲーム状態管理
- セーブ／ロード
- フラグ管理
- アイテム管理
- エンディング管理

### Core領域

Research領域とGame領域の両方から利用する共通機能を管理する。

- プレイヤーID
- セッションID
- EventBus
- 設定
- 共通定数

# Game Domain Design

## 概要

Game領域は、ゲーム進行・セーブデータ・周回要素など、
ノベルゲームとして必要な状態を管理する。

研究用ログとは分離し、ゲームの状態管理に専念する。

将来的な機能追加を想定し、
特定の作品に依存しない汎用的なデータ構造とする。

---

## RNF.state

### 役割

現在のプレイ、または現在の周回におけるゲーム状態を管理する。

### 管理するデータ

- 現在のシーン
- 現在のルート
- 到達中のエンディング
- 最後のセーブ地点
- 選択肢の回答
- 自由入力の回答
- 周回内ポイント
- ゲームフラグ
- シナリオ変数
- データバージョン
- 最終更新日時

### 初期データ構造

```javascript
{
  progress: {
    currentSceneId: null,
    currentRouteId: null,
    currentEndingId: null,
    lastSavePointId: null,
  },

  choices: {},

  textInputs: {},

  points: {},

  flags: {},

  variables: {},

  metadata: {
    stateVersion: "0.1.0",
    updatedAt: null,
  },
}

# Transport Design

## 概要

Transport領域は、ResearchStorageに蓄積された研究データを
外部の保存先へ送信する責務を持つ。

RNF本体はGoogleアカウント、スプレッドシート、
Google Apps Scriptの詳細を直接参照しない。

---

## RNF.researchStorage

### 役割

- 研究データを送信待ちキューへ保存する
- 送信待ちデータをTransportへ渡す
- 送信成功したデータをキューから削除する
- 送信失敗したデータをキューへ残す

### 知らないもの

- Googleアカウント
- Googleスプレッドシート
- Google Apps Scriptの実装
- 送信先サービス固有の仕様

---

## RNF.transport

### 役割

ResearchStorageから受け取ったデータを、
設定された外部エンドポイントへ送信する。

### 初期実装

初期段階ではHTTP POSTを利用し、
Google Apps Scriptのウェブアプリへ送信する。

### 将来の差し替え候補

- Firebase
- Supabase
- BigQuery連携API
- 大学管理サーバー
- その他の研究データ基盤

### 設計方針

- 送信先URLはconfig.jsで管理する
- Google固有の処理をRNF本体へ書かない
- 送信成功・失敗を明確に返す
- 通信失敗時にデータを失わない
- 送信成功後のみキューから削除する

---

## Google Apps Script Receiver

### 役割

- RNFからHTTP POSTで研究データを受信する
- 受信データを検証する
- 設定されたSpreadsheet IDのファイルへ保存する
- 処理結果をJSONで返す

### 設計方針

- スプレッドシートとの紐づけはSpreadsheet IDで管理する
- シート名は設定ファイルで管理する
- Googleアカウント変更時は、設定値とデプロイURLだけを変更する
- Apps ScriptのソースコードはGitHubにも保存する