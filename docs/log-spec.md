# Log Specification

## 概要

RNF（Research Novel Framework）が取得するログの仕様を定義する。

本ログは研究データとして利用されることを前提とし、
ゲームの進行状況だけでなく、被験者の回答や行動も記録する。

---

# ログ設計方針

・すべてのログは時系列で保存する
・後から分析しやすい形式にする
・Google Spreadsheetへ送信できる形式とする
・匿名化を前提とする

---

# 共通項目

すべてのログに以下を含める。

|項目|説明|
|---|---|
|sessionId|プレイ開始時に発行するID|
|playerId|プレイヤーID（匿名）|
|timestamp|記録日時|
|sceneId|現在のシーン|
|questionId|質問ID|
|eventType|イベント種類|

---

# eventType

|種類|説明|
|---|---|
|game_start|ゲーム開始|
|choice|選択肢回答|
|text_input|自由入力|
|scene_start|シーン開始|
|scene_end|シーン終了|
|game_end|ゲーム終了|

---

# choice

追加項目

|項目|説明|
|---|---|
|choiceId|選択された選択肢|
|choiceText|選択肢テキスト|

---

# text_input

追加項目

|項目|説明|
|---|---|
|inputText|自由入力内容|

---

# game_start

追加項目

なし

---

# game_end

追加項目

|項目|説明|
|---|---|
|playTime|総プレイ時間|