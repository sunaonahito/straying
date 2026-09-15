/**
 * Research Novel Framework
 * Research Logger
 *
 * ゲーム内で発生した出来事を、
 * 研究用のEvent Logとして時系列に記録する。
 */

import config from "../core/config.js";
import projectConfig from "../project/project-config.js";
import player from "../core/player.js";
import state from "../game/state.js";
import participant from "../core/participant.js";

class ResearchLogger {
  constructor() {
    this.eventLogs = [];
  }

  /**
   * イベントログを記録する。
   *
   * @param {Object} params
   * @param {string} params.eventType
   * @param {Object} [params.data]
   * @returns {Object|null}
   */
  logEvent({ eventType, data = {} }) {
    if (!config.LOG.SAVE_EVENT_LOG) {
      return null;
    }

    this.validateEventType(eventType);

    const sessionInfo = player.getSessionInfo();
    const gameState = state.getState();
    const participantInfo =
  participant.getCurrentParticipant();

    const log = {
      logId: this.generateId(),
      logType: "event",

      playerId: sessionInfo.playerId,
      sessionId: sessionInfo.sessionId,
      participantId:
      participantInfo.participantId,      
      timestamp: new Date().toISOString(),

      eventType,

      sceneId: gameState.progress.currentSceneId,
      routeId: gameState.progress.currentRouteId,
      endingId: gameState.progress.currentEndingId,

      data: structuredClone(data),
environment: config.ENVIRONMENT,

studyId: config.STUDY.STUDY_ID,

projectId: projectConfig.PROJECT_ID,

siteId: projectConfig.SITE_ID,

language: projectConfig.LANGUAGE,

scenarioVersion: projectConfig.SCENARIO_VERSION,

consentVersion: config.STUDY.CONSENT_VERSION,

frameworkVersion: config.VERSION,
    };

    this.eventLogs.push(log);

    if (config.DEBUG) {
      console.log("RNF Event Log:", structuredClone(log));
    }

    return structuredClone(log);
  }

  /**
   * 全イベントログを取得する。
   *
   * @returns {Array}
   */
  getEventLogs() {
    return structuredClone(this.eventLogs);
  }

  /**
   * イベントログの件数を取得する。
   *
   * @returns {number}
   */
  getEventLogCount() {
    return this.eventLogs.length;
  }

    /**
   * 指定Session・設問に対応するEvent Logを削除する。
   *
   * @param {Object} params
   * @param {string} params.sessionId
   * @param {string[]} params.answerIds
   * @returns {number}
   */
    removeAnswerEvents({
    sessionId,
    participantId,
    answerIds,
  }) {
    if (
      typeof sessionId !== "string" ||
      sessionId.trim() === ""
    ) {
      throw new TypeError(
        "sessionId must be a non-empty string."
      );
    }

    if (
      typeof participantId !== "string" ||
      participantId.trim() === ""
    ) {
      throw new TypeError(
        "participantId must be a non-empty string."
      );
    }

    if (
      !Array.isArray(answerIds) ||
      answerIds.some(
        (answerId) =>
          typeof answerId !== "string" ||
          answerId.trim() === ""
      )
    ) {
      throw new TypeError(
        "answerIds must be an array of non-empty strings."
      );
    }

    const answerIdSet =
      new Set(answerIds);

    const originalCount =
      this.eventLogs.length;

    this.eventLogs =
      this.eventLogs.filter((log) => {
        if (
          log.sessionId !== sessionId
        ) {
          return true;
        }

        const logParticipantId =
          log.participantId ??
          "DEFAULT";

        if (
          logParticipantId !==
          participantId
        ) {
          return true;
        }

        const eventAnswerId =
          log.data?.questionId ??
          log.data?.inputId ??
          null;

        return !answerIdSet.has(
          eventAnswerId
        );
      });

    return (
      originalCount -
      this.eventLogs.length
    );
  }

  /**
 * 指定Session・参加者に属する
 * Event Logをすべて削除する。
 *
 * @param {Object} params
 * @param {string} params.sessionId
 * @param {string} params.participantId
 * @returns {number}
 */
removeEventsByParticipant({
  sessionId,
  participantId,
}) {
  if (
    typeof sessionId !== "string" ||
    sessionId.trim() === ""
  ) {
    throw new TypeError(
      "sessionId must be a non-empty string."
    );
  }

  if (
    typeof participantId !== "string" ||
    participantId.trim() === ""
  ) {
    throw new TypeError(
      "participantId must be a non-empty string."
    );
  }

  const originalCount =
    this.eventLogs.length;

  this.eventLogs =
    this.eventLogs.filter((log) => {
      if (
        log.sessionId !==
        sessionId
      ) {
        return true;
      }

      const logParticipantId =
        log.participantId ??
        "DEFAULT";

      return (
        logParticipantId !==
        participantId
      );
    });

  return (
    originalCount -
    this.eventLogs.length
  );
}

  /**
   * イベントログを初期化する。
   */
  clearEventLogs() {
    this.eventLogs = [];
  }

  /**
   * イベント名を検証する。
   *
   * @param {*} eventType
   */
  validateEventType(eventType) {
    if (typeof eventType !== "string" || eventType.trim() === "") {
      throw new TypeError("eventType must be a non-empty string.");
    }
  }

  /**
   * ログIDを生成する。
   *
   * @returns {string}
   */
  generateId() {
    if (typeof crypto !== "undefined" && crypto.randomUUID) {
      return crypto.randomUUID();
    }

    return `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  }
}

const logger = new ResearchLogger();

export default logger;