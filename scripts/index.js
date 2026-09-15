import researchStorage from "./research/research-storage.js";
import player from "./core/player.js";
import state from "./game/state.js";
import logger from "./research/logger.js";
import answerStore from "./research/answer-store.js";
import { registerResearchListeners } from "./research/register-research-listeners.js";

import "./adapters/tyrano.js";
import "./debug/research-debug.js";

import {
  printObject,
  printTable,
  separator,
} from "./debug/debug.js";

registerResearchListeners();

const sessionInfo = player.initialize();

const localStartTime = new Date(sessionInfo.startTime).toLocaleString("ja-JP", {
  timeZone: "Asia/Tokyo",
});

console.log("Player ID :", sessionInfo.playerId);
console.log("Session ID:", sessionInfo.sessionId);
console.log("Start Time (UTC):", sessionInfo.startTime);
console.log("Start Time (JST):", localStartTime);

/**
 * ゲーム側はStateを更新するだけ。
 * LoggerとAnswer StoreはEventBus経由で自動更新される。
 */
state.setCurrentScene("SC001");
state.setCurrentRoute("ROUTE_A");

/*
state.setChoice(
  "Q001",
  "C002",
  "家族との時間を大切にする"
);

state.setTextInput(
  "I001",
  "家族との時間を大切にしたい"
);
*/

separator();

printObject("State", state.getState());

separator();

printTable(
    `Event Logs (${logger.getEventLogCount()})`,
    logger.getEventLogs()
);

separator();

printTable("Answers", answerStore.getAnswerList());

separator();

console.log("Event Count:", logger.getEventLogCount());
console.log("Answer Count:", answerStore.getAnswerCount());

separator();

printTable(
  `Research Queue (${researchStorage.getQueueCount()})`,
  researchStorage.getQueue()
);


/**
 * Research Queueの先頭1件を送信する。
 *
 * 成功した場合のみ、送信済みデータをQueueから削除する。
 */


// testResearchDispatcher();