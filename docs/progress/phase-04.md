# RNF Development Report

# Phase 4 - Event Driven Research Foundation

## Date

2026-07-14

---

# Goal

イベント駆動アーキテクチャを完成させ、
研究データ収集基盤を構築する。

---

# Completed

## EventBus

### Purpose

RNF全体のイベント通知システム。

ゲーム中に起きた出来事を、
必要なモジュールへ通知する。

### Example

```
State
    ↓
EventBus
    ↓
Logger
AnswerStore
ResearchQueue
```

### Result

ゲーム側は

```javascript
state.setChoice(...)
```

だけ呼び出せばよくなった。

研究機能をゲームコードへ直接書く必要がなくなった。

---

## Research Listener

### Purpose

EventBusから通知されたイベントを受け取り、
研究用モジュールへ橋渡しを行う。

### Result

以下の処理を自動化した。

```
EventBus

↓

Logger

↓

AnswerStore

↓

ResearchQueue
```

---

## Event Logger

### Purpose

ゲーム中に発生した出来事を
時系列で保存する。

### Stored Data

- Scene Start
- Choice Selected
- Text Input
- Ending
- Other Events

### Result

プレイヤーが

「いつ」

「どの順番で」

「何を行ったか」

を分析できるようになった。

---

## Answer Store

### Purpose

設問ごとの最新回答を保持する。

### Difference from Event Logger

Event Logger

```
Q001

↓

C001

↓

C003
```

履歴をすべて保存する。

Answer Store

```
Q001

↓

C003
```

最新状態のみ保持する。

### Result

現在の回答状態を高速に取得できるようになった。

---

## Research Queue

### Purpose

送信待ち研究データを一時保存する。

### Flow

```
Event

↓

Queue

↓

Transport

↓

Spreadsheet
```

### Result

通信失敗時でも
研究データを失わない設計になった。

---

## Debug Utilities

### Purpose

RNF専用のデバッグ支援ツール。

### Functions

- printObject()
- printTable()
- separator()

### Result

Console表示が整理され、
デバッグ効率が向上した。

---

## Transport Architecture

### Purpose

研究データを外部サービスへ送信する責務を分離する。

### Design

RNFは

- Google
- Spreadsheet
- Apps Script

を知らない。

知っているのは

```
Endpoint URL
```

のみ。

### Result

将来的に

- Google Spreadsheet
- Firebase
- Supabase
- BigQuery

などへ容易に変更可能になった。

---

## Google Apps Script Receiver

### Purpose

RNFから送信された研究データを受信し、
Spreadsheetへ保存する。

### Result

Apps Script単体テスト成功。

Spreadsheetへ正常に1件追加できることを確認。

---

# Current Architecture

```
Game
    │
    ▼

State
    │
    ▼

EventBus
    │
    ▼

Research Listener
    │
    ├────────────┐
    ▼            ▼
Logger      AnswerStore
    │            │
    └──────┬─────┘
           ▼
    ResearchQueue
           │
      (Next Phase)
           ▼
    HTTP Transport
           │
           ▼
 Google Apps Script
           │
           ▼
     Spreadsheet
```

---

# Current Progress

```
██████░░░░ 60%
```

---

# Design Principles Learned

今回もっとも重要だった設計思想。

## Single Responsibility

各モジュールは
一つの責務だけを持つ。

- State
- EventBus
- Logger
- AnswerStore
- ResearchQueue
- Transport

は互いに役割を分離している。

---

## Event Driven Architecture

ゲームコードは

```javascript
state.setChoice(...)
```

だけを実行する。

その後の

- Logger
- AnswerStore
- ResearchQueue

への処理は
EventBus経由で自動実行される。

---

## Loose Coupling

RNF本体は

- Google
- Spreadsheet
- Apps Script

へ依存しない。

Transportを差し替えるだけで
保存先を変更できる。

---

# Next Phase

## Phase 5

HTTP Transport

### Goal

Research Queueから
Apps Scriptへデータを送信する。

### Completion Criteria

- Queueから1件送信できる
- Apps Scriptが受信できる
- Spreadsheetへ保存できる
- Success Responseを受け取れる
- Queue削除はまだ行わない

---

# Notes

今回から

Consoleの成功条件を明確化する運用へ変更。

各Phase終了時に

- 完成したもの
- 設計思想
- 次回目標

を記録していく。