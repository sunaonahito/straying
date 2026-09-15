/**
 * Research Novel Framework
 * Tyrano Adapter
 *
 * ティラノスクリプトからRNFの機能を呼び出すための接続口。
 */

import state from "../game/state.js";
import player from "../core/player.js";
import researchDispatcher from "../research/research-dispatcher.js";
import researchStorage from "../research/research-storage.js";
import saveManager from "../game/save-manager.js";
import answerStore from "../research/answer-store.js";
import logger from "../research/logger.js";
import playHistory from "../game/play-history.js";
import participant from "../core/participant.js";
import participantRegistry from "../core/participant-registry.js";
import sessionParticipants from "../core/session-participants.js";
import config from "../core/config.js";
import projectConfig from "../project/project-config.js";
import consentManager from "../research/consent-manager.js";
import withdrawalCodeManager from "../research/withdrawal-code-manager.js";
import withdrawalRegistry from "../research/withdrawal-registry.js";

/**
 * ティラノの選択肢回答をRNFへ渡す。
 *
 * @param {string} questionId
 * @param {string} choiceId
 * @param {string} choiceText
 * @returns {Object}
 */
function recordChoice(
  questionId,
  choiceId,
  choiceText
) {
  if (!consentManager.hasCurrentConsent()) {
    console.warn(
      "RNF Tyrano Adapter: Consent未取得のためChoiceを記録しません。"
    );

    return {
      success: false,
      reason: "consent_required",
      message:
        "Consent is required before recording research answers.",
    };
  }

  if (!questionId || !choiceId) {
    console.error(
      "RNF Tyrano Adapter: questionIdとchoiceIdが必要です。"
    );

    return {
      success: false,
      message:
        "questionIdとchoiceIdが必要です。",
    };
  }

  state.setChoice(
    String(questionId),
    String(choiceId),
    String(choiceText ?? "")
  );

  const result = {
    success: true,
    type: "choice",
    questionId:
      String(questionId),
    choiceId:
      String(choiceId),
    choiceText:
      String(choiceText ?? ""),
  };

  console.log(
    "✅ Tyrano choice recorded:",
    result
  );

  return result;
}

/**
 * ティラノの自由入力回答をRNFへ渡す。
 *
 * @param {string} inputId
 * @param {string} inputText
 * @returns {Object}
 */
function recordTextInput(
  inputId,
  inputText
) {
  if (!consentManager.hasCurrentConsent()) {
    console.warn(
      "RNF Tyrano Adapter: Consent未取得のためText Inputを記録しません。"
    );

    return {
      success: false,
      reason: "consent_required",
      message:
        "Consent is required before recording research answers.",
    };
  }

  if (!inputId) {
    console.error(
      "RNF Tyrano Adapter: inputIdが必要です。"
    );

    return {
      success: false,
      message:
        "inputIdが必要です。",
    };
  }

  state.setTextInput(
    String(inputId),
    String(inputText ?? "")
  );

  const result = {
    success: true,
    type: "text",
    inputId:
      String(inputId),
    inputText:
      String(inputText ?? ""),
  };

  console.log(
    "✅ Tyrano text input recorded:",
    result
  );

  return result;
}

/**
 * 現在のシーンIDをRNFへ渡す。
 *
 * @param {string} sceneId
 * @returns {Object}
 */
function setScene(sceneId) {
  state.setCurrentScene(String(sceneId));

  const result = {
    success: true,
    sceneId: String(sceneId),
  };

  console.log(
    "✅ Tyrano scene recorded:",
    sceneId
  );

  return result;
}

/**
 * 現在のルートIDをRNFへ渡す。
 *
 * @param {string} routeId
 * @returns {Object}
 */
function setRoute(routeId) {
  state.setCurrentRoute(String(routeId));

  const result = {
    success: true,
    routeId: String(routeId),
  };

  console.log(
    "✅ Tyrano route recorded:",
    routeId
  );

  return result;
}

/**
 * 新しいプレイセッションを開始する。
 *
 * @returns {Object}
 */
function startNewSession() {
  sessionParticipants.reset();

  const sessionInfo =
    player.startNewSession();

  console.log(
    "✅ Tyrano new session started:",
    sessionInfo
  );

  return {
    success: true,
    ...sessionInfo,
  };
}

/**
 * 現在のセッション情報を取得する。
 *
 * @returns {Object}
 */
function getSessionInfo() {
  return player.getSessionInfo();
}

/**
 * 現在のプレイ状態を保存する。
 *
 * @param {Object} data
 * @returns {Object}
 */
function saveCurrentPlay(data) {
  return saveManager.save(data);
}

/**
 * 保存済みのプレイ状態を取得する。
 *
 * @returns {Object|null}
 */
function loadCurrentPlay() {
  return saveManager.load();
}

/**
 * 保存済みのプレイ状態があるか確認する。
 *
 * @returns {boolean}
 */
function hasCurrentPlaySave() {
  return saveManager.hasSave();
}

/**
 * 現在のプレイ保存データを削除する。
 */
function clearCurrentPlaySave() {
  saveManager.clear();
}

/**
 * 保存済みプレイを復元する。
 *
 * @returns {Object|null}
 */
function restoreCurrentPlay() {
  return saveManager.restore();
}

/**
 * 現在回答中の参加者の回答一覧を取得する。
 *
 * @returns {Array}
 */
function getCurrentAnswers() {
  return answerStore
    .getCurrentParticipantAnswerList();
}

/**
 * 現在のSession内に記録された
 * 全参加者の回答一覧を取得する。
 *
 * @returns {Array}
 */
function getSessionAnswers() {
  return answerStore
    .getAnswerList();
}

/**
 * Research Queueの全データを順番に送信する。
 *
 * @returns {Promise<Object>}
 */
async function sendAllResearchRecords() {
  console.log(
    "RNF Tyrano Adapter: 一括送信を開始します。"
  );

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
      "❌ Tyrano research dispatch failed:",
      result
    );

    return result;
  }

  console.log(
    "✅ Tyrano research dispatch succeeded:",
    result
  );

  return result;
}

/**
 * Research Queueの現在件数を返す。
 *
 * @returns {number}
 */
function getResearchQueueCount() {
  return researchStorage.getQueueCount();
}

/**
 * 現在の参加者の指定回答を取り消す。
 *
 * Queue、Event Log、Answer Store、
 * Game State、途中保存を整理する。
 *
 * @param {string[]} answerIds
 * @returns {Object}
 */
function restartCurrentAnswers(
  answerIds
) {
  if (
    !Array.isArray(answerIds) ||
    answerIds.length === 0
  ) {
    throw new TypeError(
      "answerIds must be a non-empty array."
    );
  }

  const sessionId =
    player.getSessionInfo().sessionId;

  const participantInfo =
    participant
      .getCurrentParticipant();

  const participantId =
    participantInfo.participantId;

  const queueResult =
    researchStorage
      .removeCurrentSessionAnswerRecords({
        sessionId,
        participantId,
        answerIds,
      });

  const removedEventCount =
  logger.removeAnswerEvents({
    sessionId,
    participantId,
    answerIds,
  });

  let removedAnswerCount = 0;
  let removedChoiceCount = 0;
  let removedTextInputCount = 0;

  answerIds.forEach(
    (answerId) => {
      if (
        answerStore.removeAnswer(
          answerId
        )
      ) {
        removedAnswerCount += 1;
      }

      if (
        state.removeChoice(
          answerId
        )
      ) {
        removedChoiceCount += 1;
      }

      if (
        state.removeTextInput(
          answerId
        )
      ) {
        removedTextInputCount += 1;
      }
    }
  );

  saveManager.clear();

  const result = {
    success: true,
    sessionId,
    participantId,

    participantName:
      participantInfo.displayName,

    removedQueueCount:
      queueResult.removedCount,

    remainingQueueCount:
      queueResult.remainingCount,

    removedEventCount,
    removedAnswerCount,
    removedChoiceCount,
    removedTextInputCount,
  };

  console.log(
    "✅ RNF participant answers restarted:",
    result
  );

  return result;
}

/**
 * 現在のプレイを完了履歴へ保存する。
 *
 * @returns {Object}
 */
function saveCurrentPlayHistory() {
  const result =
    playHistory.saveCurrentPlay();

  console.log(
    "✅ RNF play history:",
    result
  );

  return result;
}

/**
 * 完了済みプレイ履歴を取得する。
 *
 * @returns {Array}
 */
function getPlayHistory() {
  return playHistory.getHistory();
}

/**
 * 最新の完了プレイを取得する。
 *
 * @returns {Object|null}
 */
function getLatestPlayHistory() {
  return playHistory.getLatest();
}

/**
 * 完了済みプレイ履歴の件数を取得する。
 *
 * @returns {number}
 */
function getPlayHistoryCount() {
  return playHistory.getCount();
}

/**
 * 現在のプレイヤーにおける
 * 前回の完了プレイを取得する。
 *
 * @returns {Object|null}
 */
function getPreviousPlayHistory() {
  return playHistory
    .getPreviousForCurrentParticipant();
}

/**
 * 前回プレイの回答を
 * answerId別に取得する。
 *
 * @returns {Object|null}
 */
function getPreviousPlayAnswers() {
  if (
    !config.FEATURES
      .SHOW_PREVIOUS_PLAY_ANSWERS
  ) {
    return null;
  }

  return playHistory
    .getPreviousAnswersForCurrentParticipant();
}

/**
 * 現在回答中の参加者を設定する。
 *
 * @param {Object} participantInfo
 * @returns {Object}
 */
function setCurrentParticipant(
  participantInfo
) {
  return participant
    .setCurrentParticipant(
      participantInfo
    );
}

/**
 * 現在回答中の参加者を取得する。
 *
 * @returns {Object}
 */
function getCurrentParticipant() {
  return participant
    .getCurrentParticipant();
}

/**
 * 参加者設定を初期状態へ戻す。
 *
 * @returns {Object}
 */
function resetCurrentParticipant() {
  return participant.reset();
}

/**
 * 名前から参加者を取得または新規登録し、
 * 現在の参加者として設定する。
 *
 * @param {string} displayName
 * @returns {Object}
 */
function selectParticipantByName(
  displayName
) {
  const registeredParticipant =
    participantRegistry
      .getOrCreateByName(
        displayName
      );

  return participant
    .setCurrentParticipant({
      participantId:
        registeredParticipant
          .participantId,

      displayName:
        registeredParticipant
          .displayName,
    });
}

/**
 * 登録済み参加者一覧を取得する。
 *
 * @returns {Array}
 */
function getRegisteredParticipants() {
  return participantRegistry
    .getParticipants();
}

/**
 * Participant IDを指定して、
 * 登録済み参加者を現在の回答者に設定する。
 *
 * @param {string} participantId
 * @returns {Object}
 */
function selectParticipantById(
  participantId
) {
  const registeredParticipant =
    participantRegistry.getById(
      participantId
    );

  if (!registeredParticipant) {
    throw new Error(
      "Registered participant was not found."
    );
  }

  return participant
    .setCurrentParticipant({
      participantId:
        registeredParticipant
          .participantId,

      displayName:
        registeredParticipant
          .displayName,
    });
}

/**
 * 名前を指定して今回のSessionへ
 * 参加者を追加する。
 *
 * @param {string} displayName
 * @returns {Object}
 */
function addSessionParticipantByName(
  displayName
) {
  const registeredParticipant =
    participantRegistry
      .getOrCreateByName(
        displayName
      );

  return sessionParticipants
    .addParticipant({
      participantId:
        registeredParticipant
          .participantId,

      displayName:
        registeredParticipant
          .displayName,
    });
}

/**
 * 登録済みParticipant IDを指定して
 * 今回のSessionへ参加者を追加する。
 *
 * @param {string} participantId
 * @returns {Object}
 */
function addSessionParticipantById(
  participantId
) {
  const registeredParticipant =
    participantRegistry.getById(
      participantId
    );

  if (!registeredParticipant) {
    throw new Error(
      "Registered participant was not found."
    );
  }

  return sessionParticipants
    .addParticipant({
      participantId:
        registeredParticipant
          .participantId,

      displayName:
        registeredParticipant
          .displayName,
    });
}

/**
 * 今回のSession参加者一覧を取得する。
 *
 * @returns {Array}
 */
function getSessionParticipants() {
  return sessionParticipants
    .getParticipants();
}

/**
 * Session参加者数を取得する。
 *
 * @returns {number}
 */
function getSessionParticipantCount() {
  return sessionParticipants
    .getParticipantCount();
}

/**
 * 最初のSession参加者を
 * 現在の回答者に設定する。
 *
 * @returns {Object|null}
 */
function selectFirstSessionParticipant() {
  return sessionParticipants
    .selectFirst();
}

/**
 * Participant IDを指定して
 * 現在の回答者に設定する。
 *
 * @param {string} participantId
 * @returns {Object}
 */
function selectSessionParticipantById(
  participantId
) {
  return sessionParticipants
    .selectById(participantId);
}

/**
 * 次のSession参加者へ切り替える。
 *
 * @returns {Object}
 */
function selectNextSessionParticipant() {
  return sessionParticipants
    .selectNext();
}

/**
 * 現在のSession参加状況を取得する。
 *
 * @returns {Object}
 */
function getSessionParticipantStatus() {
  return sessionParticipants
    .getStatus();
}

/**
 * 登録済み参加者をParticipant IDで削除する。
 *
 * @param {string} participantId
 * @returns {boolean}
 */
function removeRegisteredParticipant(
  participantId
) {
  return participantRegistry
    .removeById(participantId);
}

/**
 * 登録済み参加者をすべて削除する。
 *
 * @returns {number}
 */
function clearRegisteredParticipants() {
  return participantRegistry
    .clearParticipants();
}

/**
 * 現在のゲーム状態を取得する。
 *
 * @returns {Object}
 */
function getState() {
  return state.getState();
}

/**
 * Event Log一覧を取得する。
 *
 * @returns {Array}
 */
function getEventLogs() {
  return logger.getEventLogs();
}

/**
 * Session参加者一覧を初期化する。
 */
function resetSessionParticipants() {
  sessionParticipants.reset();

  return sessionParticipants
    .getStatus();
}

/**
 * 現在の作品設定を取得する。
 *
 * @returns {Object}
 */
function getProjectConfig() {
  return projectConfig;
}

/**
 * 現在の参加者について研究参加への同意を記録する。
 *
 * @returns {Object}
 */
function recordConsent() {
  return consentManager.recordConsent();
}

/**
 * 現在の参加者の同意記録を取得する。
 *
 * @returns {Object|null}
 */
function getCurrentConsent() {
  return consentManager.getCurrentConsent();
}

/**
 * 現在の参加者が有効な同意状態か確認する。
 *
 * @returns {boolean}
 */
function hasCurrentConsent() {
  return consentManager.hasCurrentConsent();
}

/**
 * 現在の参加者の同意を撤回する。
 *
 * @returns {Object|null}
 */
function withdrawCurrentConsent() {
  return consentManager.withdrawCurrentConsent();
}

/**
 * 現在の参加者の同意記録を削除する。
 *
 * @returns {boolean}
 */
function removeCurrentConsent() {
  return consentManager.removeCurrentConsent();
}

/**
 * 端末内の全同意記録を削除する。
 *
 * @returns {number}
 */
function clearConsentRecords() {
  return consentManager.clearConsentRecords();
}

/**
 * 端末内の全同意記録を取得する。
 *
 * @returns {Array}
 */
function getConsentRecords() {
  return consentManager.getConsentRecords();
}

/**
 * 現在の参加者が研究参加を撤回する。
 *
 * 端末内に残っている現在参加者の研究関連データを削除し、
 * 同意状態を撤回済みに変更する。
 *
 * @returns {Object}
 */
function withdrawResearchParticipation() {
  const sessionInfo =
    player.getSessionInfo();

  const participantInfo =
    participant.getCurrentParticipant();

  const participantId =
    participantInfo.participantId;

  const sessionId =
    sessionInfo.sessionId;

  /*
   * 1. 同意を撤回状態へ変更
   */
  const consentResult =
    consentManager
      .withdrawCurrentConsent();

  /*
   * 2. 未送信Research Queueを
   *    全Session横断で削除
   */
  const queueResult =
    researchStorage
      .removeRecordsByParticipant(
        participantId
      );

  /*
   * 3. Answer Logを削除
   */
  const removedAnswerCount =
    answerStore
      .removeAnswersByParticipant(
        participantId
      );

  /*
   * 4. Event Logを削除
   */
  const removedEventCount =
    logger
      .removeEventsByParticipant({
        sessionId,
        participantId,
      });

  /*
   * 5. Game State内の
   *    Choice / Text Inputを削除
   */
  const stateResult =
    state
      .removeParticipantData(
        participantId
      );

  /*
   * 6. Play Historyから
   *    対象参加者の情報を削除
   */
  const historyResult =
    playHistory
      .removeParticipantData(
        participantId
      );

  /*
   * 7. Session参加者一覧から削除
   */
  const sessionParticipantResult =
    sessionParticipants
      .removeParticipantById(
        participantId
      );

  /*
   * 8. Participant Registryから削除
   */
  const registryRemoved =
    participantRegistry
      .removeById(
        participantId
      );

  /*
   * 9. 撤回者を除いた現在状態で
   *    途中保存を再構築
   */
  const saveResult =
    saveManager
      .removeParticipantData(
        participantId
      );

  const result = {
    success: true,

    participantId,
    sessionId,

    consent:
      consentResult,

    removedResearchQueueCount:
      queueResult.removedCount,

    remainingResearchQueueCount:
      queueResult.remainingCount,

    removedAnswerCount,

    removedEventCount,

    removedStateChoiceCount:
      stateResult.removedChoiceCount,

    removedStateTextInputCount:
      stateResult.removedTextInputCount,

    history:
      historyResult,

    sessionParticipants:
      sessionParticipantResult,

    participantRegistryRemoved:
      registryRemoved,

    save:
      saveResult,
  };

  console.log(
    "✅ RNF research participation withdrawn:",
    result
  );

  return result;
}

/**
 * 撤回コードを生成する。
 *
 * @returns {string|null}
 */
function generateWithdrawalCode() {
  return withdrawalCodeManager.generateCode();
}

/**
 * 現在の参加者にWithdrawal Codeを発行して登録する。
 *
 * すでに登録済みの場合は既存コードを返す。
 *
 * @returns {Object|null}
 */
function registerWithdrawalCodeForCurrentParticipant() {
  const participantInfo =
    participant.getCurrentParticipant();

  if (!participantInfo) {
    throw new Error(
      "No current participant is selected."
    );
  }

  const participantId =
    participantInfo.participantId;

  const existing =
    withdrawalRegistry
      .getByParticipantId(
        participantId
      );

  if (existing) {
    return existing;
  }

  const withdrawalCode =
    withdrawalCodeManager
      .generateCode();

  if (!withdrawalCode) {
    return null;
  }

  return withdrawalRegistry.register({
    withdrawalCode,
    participantId,
  });
}

/**
 * Withdrawal Codeから登録情報を取得する。
 *
 * @param {string} withdrawalCode
 * @returns {Object|null}
 */
function getWithdrawalRecordByCode(
  withdrawalCode
) {
  return withdrawalRegistry
    .getByWithdrawalCode(
      withdrawalCode
    );
}

/**
 * Withdrawal Registryを取得する。
 *
 * @returns {Array}
 */
function getWithdrawalRecords() {
  return withdrawalRegistry
    .getRecords();
}

/**
 * 現在の参加者について研究参加を開始する。
 *
 * Consentを記録し、
 * Withdrawal Codeを発行する。
 *
 * @returns {{
 *   consent: Object,
 *   withdrawal: Object|null
 * }}
 */
function startResearchParticipation() {
  const participantInfo =
    participant.getCurrentParticipant();

  if (!participantInfo) {
    throw new Error(
      "No current participant is selected."
    );
  }

  const consent =
    consentManager.recordConsent();

  const withdrawal =
    registerWithdrawalCodeForCurrentParticipant();

  const result = {
    consent,
    withdrawal,
  };

  console.log(
    "✅ RNF research participation started:",
    result
  );

  return result;
}

/**
 * 匿名Participantを新規作成し、
 * Sessionへ追加して現在参加者に選択する。
 *
 * @returns {Object}
 */
function initializeAnonymousParticipant() {
  const anonymousParticipant =
    participantRegistry
      .createAnonymousParticipant();

  sessionParticipants
    .addParticipant({
      participantId:
        anonymousParticipant
          .participantId,

      displayName:
        anonymousParticipant
          .displayName,
    });

  sessionParticipants
    .selectById(
      anonymousParticipant
        .participantId
    );

  const result = {
    participant:
      participant
        .getCurrentParticipant(),

    session:
      sessionParticipants
        .getStatus(),
  };

  console.log(
    "✅ RNF anonymous participant initialized:",
    result
  );

  return result;
}

/**
 * RNFの現在状態を簡易診断する。
 *
 * @returns {Object}
 */
function diagnoseRNF() {
  const currentParticipant =
    participant.getCurrentParticipant();

  const sessionStatus =
    sessionParticipants.getStatus();

  const consent =
    consentManager.getCurrentConsent();

  const project =
    projectConfig;

  const queueCount =
    researchStorage.getQueueCount();

  const issues = [];

  if (!project) {
    issues.push(
      "Project configuration is not available."
    );
  }

  if (!currentParticipant) {
    issues.push(
      "No current participant is selected."
    );
  }

  if (
    sessionStatus.participantCount === 0
  ) {
    issues.push(
      "No session participants are registered."
    );
  }

  if (
    currentParticipant &&
    !consentManager.hasCurrentConsent()
  ) {
    issues.push(
      "Current participant has no valid consent."
    );
  }

  if (queueCount > 0) {
    issues.push(
      `${queueCount} research record(s) are waiting to be sent.`
    );
  }

  const result = {
    healthy:
      issues.length === 0,

    project: {
      projectId:
        project?.PROJECT_ID ?? null,

      siteId:
        project?.SITE_ID ?? null,

      language:
        project?.LANGUAGE ?? null,

      scenarioVersion:
        project?.SCENARIO_VERSION ??
        null,
    },

    participant:
      currentParticipant,

    session:
      sessionStatus,

    consent: {
      valid:
        consentManager
          .hasCurrentConsent(),

      record:
        consent,
    },

    researchQueue: {
      count:
        queueCount,
    },

    issues,
  };

  if (result.healthy) {
    console.log(
      "✅ RNF diagnosis: healthy",
      result
    );
  } else {
    console.warn(
      "⚠️ RNF diagnosis found issues:",
      result
    );
  }

  return result;
}

/**
 * ティラノ側から利用できる命令を公開する。
 */
window.RNF = {
  getProjectConfig,
  recordChoice,
  recordTextInput,
  setScene,
  setRoute,

  startNewSession,
  getSessionInfo,

  setCurrentParticipant,
  getCurrentParticipant,
  resetCurrentParticipant,

  selectParticipantByName,
  selectParticipantById,
  getRegisteredParticipants,
　removeRegisteredParticipant,
　clearRegisteredParticipants,

  addSessionParticipantByName,
  addSessionParticipantById,
  getSessionParticipants,
  getSessionParticipantCount,
  selectFirstSessionParticipant,
  selectSessionParticipantById,
  selectNextSessionParticipant,
  getSessionParticipantStatus,
  resetSessionParticipants,

  initializeAnonymousParticipant,

  saveCurrentPlay,
  loadCurrentPlay,
  restoreCurrentPlay,
  hasCurrentPlaySave,
  clearCurrentPlaySave,

  getCurrentAnswers,
  getSessionAnswers,
  getState,
  getEventLogs,
  restartCurrentAnswers,

  saveCurrentPlayHistory,
  getPlayHistory,
  getLatestPlayHistory,
  getPlayHistoryCount,
  getPreviousPlayHistory,
  getPreviousPlayAnswers,

  sendAllResearchRecords,
  getResearchQueueCount,

  recordConsent,
　getCurrentConsent,
　hasCurrentConsent,
　withdrawCurrentConsent,
　removeCurrentConsent,
　clearConsentRecords,
　getConsentRecords,

　generateWithdrawalCode,
　registerWithdrawalCodeForCurrentParticipant,
　getWithdrawalRecordByCode,
　getWithdrawalRecords,

　startResearchParticipation,
　withdrawResearchParticipation,

　diagnoseRNF,
};

console.log("RNF Tyrano Adapter loaded");