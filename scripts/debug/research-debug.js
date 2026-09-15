/**
 * Research Novel Framework
 * Research Debug Utilities
 *
 * ブラウザのConsoleから、研究データの追加・確認・送信を行う。
 */

import state from "../game/state.js";
import researchDispatcher from "../research/research-dispatcher.js";
import researchStorage from "../research/research-storage.js";
import { printTable } from "./debug.js";

/**
 * テスト用の選択肢回答を1回発生させる。
 *
 * EventとAnswerが各1件生成されるため、
 * Research Queueには合計2件追加される。
 */
function addTestChoice() {
  const queueCountBefore = researchStorage.getQueueCount();

  state.setChoice(
    "DEBUG_Q001",
    "DEBUG_C001",
    "デバッグ用の回答"
  );

  const queueCountAfter = researchStorage.getQueueCount();

  console.log("✅ テスト回答を追加しました。");
  console.log("追加前のQueue件数:", queueCountBefore);
  console.log("追加後のQueue件数:", queueCountAfter);

  printTable(
    `Research Queue (${queueCountAfter})`,
    researchStorage.getQueue()
  );

  return {
    success: true,
    queueCountBefore,
    queueCountAfter,
  };
}

/**
 * Research Queueの現在の状態を表示する。
 */
function showResearchQueue() {
  const queue = researchStorage.getQueue();

  console.log("Research Queue件数:", queue.length);

  printTable(
    `Research Queue (${queue.length})`,
    queue
  );

  return queue;
}

/**
 * Research Queueの先頭1件を送信する。
 */
async function sendNextResearchRecord() {
  console.log(
    "送信前のQueue件数:",
    researchStorage.getQueueCount()
  );

  try {
    const result =
      await researchDispatcher.sendNext();

    if (result.status === "empty") {
      console.warn(result.message);
      return result;
    }

    if (result.status === "busy") {
      console.warn(result.message);
      return result;
    }

    console.log(
      "✅ RNF Dispatch succeeded:",
      result
    );

    console.log(
      "送信後のQueue件数:",
      researchStorage.getQueueCount()
    );

    printTable(
      `Research Queue after send (${researchStorage.getQueueCount()})`,
      researchStorage.getQueue()
    );

    return result;
  } catch (error) {
    console.error(
      "❌ RNF Dispatch failed:",
      error
    );

    console.log(
      "送信に失敗したためQueueは削除されていません:",
      researchStorage.getQueueCount()
    );

    return {
      success: false,
      status: "failed",
      remainingCount:
        researchStorage.getQueueCount(),
      error,
    };
  }
}

/**
 * Research Queue内の全データを順番に送信する。
 */
async function sendAllResearchRecords() {
  console.log("一括送信を開始します。");

  const result =
    await researchDispatcher.sendAll();

  if (result.status === "empty") {
    console.warn(result.message);
    return result;
  }

  if (result.status === "busy") {
    console.warn(result.message);
    return result;
  }

  if (!result.success) {
    console.error(
      "❌ 一括送信を途中で停止しました:",
      result
    );

    printTable(
      `Research Queue after failure (${result.remainingCount})`,
      researchStorage.getQueue()
    );

    return result;
  }

  console.log(
    "✅ 一括送信が完了しました:",
    result
  );

  printTable(
    `Research Queue after send all (${result.remainingCount})`,
    researchStorage.getQueue()
  );

  return result;
}

/**
 * 現在の送信状態を表示する。
 */
function getDispatchStatus() {
  const status =
    researchDispatcher.getStatus();

  console.log(
    "RNF Dispatch Status:",
    status
  );

  return status;
}

window.RNFDebug = {
  addTestChoice,
  showResearchQueue,
  sendNextResearchRecord,
  sendAllResearchRecords,
  getDispatchStatus,
};

console.log("RNFDebug loaded");