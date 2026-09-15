/**
 * Research Novel Framework
 * Save Manager
 *
 * 現在のプレイ途中の状態を保存・復元する。
 */

import player from "../core/player.js";
import state from "./state.js";
import answerStore from "../research/answer-store.js";
import participant from "../core/participant.js";
import sessionParticipants from "../core/session-participants.js";

class SaveManager {
  constructor() {
    this.storageKey = "rnf_current_play_save";
  }

  /**
   * 現在のプレイ状態を保存する。
   *
   * @param {Object} data
   * @returns {Object}
   */
  save(data = {}) {
    const sessionInfo = player.getSessionInfo();

  const saveData = {
  sessionId: sessionInfo.sessionId,

  currentStep:
    data.currentStep ?? "entry",

  playMode:
  　data.playMode ?? "",

  choiceText:
    data.choiceText ?? "",

  textAnswer:
    data.textAnswer ?? "",

  participant:
    participant.getCurrentParticipant(),

  sessionParticipants:
    sessionParticipants.getStatus(),

  gameState:
    state.getState(),

  answers:
    answerStore.getAnswers(),

  updatedAt:
    new Date().toISOString(),
};

    localStorage.setItem(
      this.storageKey,
      JSON.stringify(saveData)
    );

    return structuredClone(saveData);
  }

  /**
   * 保存済みデータを読み込む。
   *
   * 現在のSession IDと一致しない保存データは無効とする。
   *
   * @returns {Object|null}
   */
  load() {
    const rawData = localStorage.getItem(
      this.storageKey
    );

    if (!rawData) {
      return null;
    }

    try {
      const saveData = JSON.parse(rawData);

      const currentSessionId =
        player.getSessionInfo().sessionId;

      if (
        !saveData.sessionId ||
        saveData.sessionId !== currentSessionId
      ) {
        return null;
      }

      return structuredClone(saveData);
    } catch (error) {
      console.warn(
        "RNF save data could not be loaded:",
        error
      );

      return null;
    }
  }

  /**
   * 保存データを読み込み、
   * StateとAnswer Storeも復元する。
   *
   * @returns {Object|null}
   */
  restore() {
    const saveData = this.load();

    if (!saveData) {
      return null;
    }

if (saveData.sessionParticipants) {
  sessionParticipants.restore(
    saveData.sessionParticipants
  );
} else if (saveData.participant) {
  participant.setCurrentParticipant(
    saveData.participant
  );
}

    if (saveData.gameState) {
      state.restore(saveData.gameState);
    }

    if (saveData.answers) {
      answerStore.restoreAnswers(
        saveData.answers
      );
    }

    return structuredClone(saveData);
  }

  /**
   * 保存済みデータがあるか確認する。
   *
   * @returns {boolean}
   */
  hasSave() {
    return this.load() !== null;
  }

  /**
 * 指定参加者の情報を
 * 現在の途中保存から削除する。
 *
 * 他の参加者が残っている場合は、
 * 現在のRNF状態から途中保存を作り直す。
 *
 * 参加者が1人も残っていない場合は、
 * 途中保存そのものを削除する。
 *
 * @param {string} participantId
 * @returns {{
 *   updated: boolean,
 *   cleared: boolean,
 *   remainingParticipantCount: number
 * }}
 */
removeParticipantData(
  participantId
) {
  if (
    typeof participantId !== "string" ||
    participantId.trim() === ""
  ) {
    throw new TypeError(
      "participantId must be a non-empty string."
    );
  }

  const rawData =
    localStorage.getItem(
      this.storageKey
    );

  if (!rawData) {
    return {
      updated: false,
      cleared: false,
      remainingParticipantCount:
        sessionParticipants
          .getParticipantCount(),
    };
  }

  const remainingParticipantCount =
    sessionParticipants
      .getParticipantCount();

  /*
   * 撤回後、Session参加者が
   * 1人も残っていない場合は
   * 途中保存を丸ごと削除する。
   */
  if (
    remainingParticipantCount === 0
  ) {
    this.clear();

    return {
      updated: true,
      cleared: true,
      remainingParticipantCount: 0,
    };
  }

  /*
   * 他の参加者が残っている場合は、
   * すでに撤回者を除去した現在の
   * State / Answer Store /
   * Session Participant情報で
   * 途中保存を作り直す。
   *
   * choiceText / textAnswer は
   * 撤回者の表示用回答が残らないよう
   * 空にする。
   */
  let previousSave = {};

  try {
    previousSave =
      JSON.parse(rawData);
  } catch (error) {
    console.warn(
      "RNF save data could not be parsed during participant removal:",
      error
    );
  }

  this.save({
    currentStep:
      previousSave.currentStep ??
      "entry",

    playMode:
      previousSave.playMode ??
      "",

    choiceText: "",
    textAnswer: "",
  });

  return {
    updated: true,
    cleared: false,
    remainingParticipantCount,
  };
}

  /**
   * 保存済みデータを削除する。
   */
  clear() {
    localStorage.removeItem(
      this.storageKey
    );
  }
}

const saveManager = new SaveManager();

export default saveManager;