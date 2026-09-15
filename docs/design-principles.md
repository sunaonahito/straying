# Design Principles

Research Novel Framework が長く利用されるための設計原則。

---

## 1. Separation of Concerns

表示と処理を分離する。

ティラノスクリプトは表示を担当し、
RNFは研究機能とゲームロジックを担当する。

---

## 2. Event Driven

モジュール同士は直接呼び出さず、
EventBusを介して連携する。

---

## 3. Research First

研究データの品質を最優先にする。

ログ取得は標準機能とする。

---

## 4. Game Independent

RNFはゲームエンジンに依存しない。

ティラノスクリプトはAdapterとして扱う。

---

## 5. AI Friendly

AIが理解しやすい構造を維持する。

責務を明確にし、
小さなモジュールへ分割する。

---

## 6. Extendable

将来的な研究テーマ追加を前提とする。

心理学だけでなく、
教育・医療・福祉などへも利用可能な設計とする。
