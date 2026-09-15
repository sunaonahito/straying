/**
 * Research Novel Framework
 * Answer Store
 *
 * 選択肢や自由入力などの回答を、
 * 参加者IDと設問IDの組み合わせごとに
 * 最新状態として管理する。
 */

import config from "../core/config.js";
import player from "../core/player.js";
import state from "../game/state.js";
import participant from "../core/participant.js";
import projectConfig from "../project/project-config.js";

class AnswerStore {
  constructor() {
    this.answers = {};
  }

  /**
   * 単一選択の回答を保存する。
   *
   * @param {Object} params
   * @param {string} params.questionId
   * @param {string} params.choiceId
   * @param {string} [params.choiceText]
   * @returns {Object|null}
   */
  saveChoice({
    questionId,
    choiceId,
    choiceText = null,
  }) {
    if (!config.LOG.SAVE_ANSWER_LOG) {
      return null;
    }

    this.validateId(
      questionId,
      "questionId"
    );

    this.validateId(
      choiceId,
      "choiceId"
    );

    return this.saveAnswer({
      answerId: questionId,
      answerType: "choice",
      value: choiceId,
      displayValue: choiceText,
    });
  }

  /**
   * 自由入力の回答を保存する。
   *
   * @param {Object} params
   * @param {string} params.inputId
   * @param {string} params.inputText
   * @returns {Object|null}
   */
  saveTextInput({
    inputId,
    inputText,
  }) {
    if (!config.LOG.SAVE_ANSWER_LOG) {
      return null;
    }

    this.validateId(
      inputId,
      "inputId"
    );

    if (typeof inputText !== "string") {
      throw new TypeError(
        "inputText must be a string."
      );
    }

    return this.saveAnswer({
      answerId: inputId,
      answerType: "text_input",
      value: inputText,
      displayValue: inputText,
    });
  }

  /**
   * 回答を共通形式で保存する。
   *
   * @param {Object} params
   * @param {string} params.answerId
   * @param {string} params.answerType
   * @param {*} params.value
   * @param {*} params.displayValue
   * @returns {Object}
   */
  saveAnswer({
    answerId,
    answerType,
    value,
    displayValue,
  }) {
    const sessionInfo =
      player.getSessionInfo();

    const gameState =
      state.getState();

    const participantInfo =
      participant
        .getCurrentParticipant();

    const answer = {
      answerId,
      answerType,

      playerId:
        sessionInfo.playerId,

      sessionId:
        sessionInfo.sessionId,

      participantId:
        participantInfo.participantId,

      sceneId:
        gameState.progress
          .currentSceneId,

      routeId:
        gameState.progress
          .currentRouteId,

      value,
      displayValue,

      answeredAt:
        new Date().toISOString(),

environment:
  config.ENVIRONMENT,

studyId:
  config.STUDY.STUDY_ID,

projectId:
  projectConfig.PROJECT_ID,

siteId:
  projectConfig.SITE_ID,

language:
  projectConfig.LANGUAGE,

scenarioVersion:
  projectConfig.SCENARIO_VERSION,

consentVersion:
  config.STUDY.CONSENT_VERSION,

frameworkVersion:
  config.VERSION,
    };

    const storageKey =
      this.createStorageKey(
        participantInfo.participantId,
        answerId
      );

    this.answers[storageKey] =
      answer;

    if (config.DEBUG) {
      console.log(
        "RNF Answer:",
        structuredClone(answer)
      );
    }

    return structuredClone(answer);
  }

  /**
   * 現在の参加者の指定回答を取得する。
   *
   * @param {string} answerId
   * @returns {Object|null}
   */
  getAnswer(answerId) {
    this.validateId(
      answerId,
      "answerId"
    );

    const participantInfo =
      participant
        .getCurrentParticipant();

    return this.getAnswerByParticipant(
      participantInfo.participantId,
      answerId
    );
  }

  /**
   * 参加者IDと回答IDを指定して取得する。
   *
   * @param {string} participantId
   * @param {string} answerId
   * @returns {Object|null}
   */
  getAnswerByParticipant(
    participantId,
    answerId
  ) {
    this.validateId(
      participantId,
      "participantId"
    );

    this.validateId(
      answerId,
      "answerId"
    );

    const storageKey =
      this.createStorageKey(
        participantId,
        answerId
      );

    const answer =
      this.answers[storageKey];

    return answer
      ? structuredClone(answer)
      : null;
  }

  /**
   * 全参加者の全回答を
   * オブジェクト形式で取得する。
   *
   * @returns {Object}
   */
  getAnswers() {
    return structuredClone(
      this.answers
    );
  }

  /**
   * 全参加者の全回答を
   * 配列形式で取得する。
   *
   * @returns {Array}
   */
  getAnswerList() {
    return Object.values(
      structuredClone(this.answers)
    );
  }

  /**
   * 現在の参加者の回答一覧を取得する。
   *
   * @returns {Array}
   */
  getCurrentParticipantAnswerList() {
    const participantInfo =
      participant
        .getCurrentParticipant();

    return this
      .getAnswersByParticipant(
        participantInfo.participantId
      );
  }

  /**
   * 指定参加者の回答一覧を取得する。
   *
   * @param {string} participantId
   * @returns {Array}
   */
  getAnswersByParticipant(
    participantId
  ) {
    this.validateId(
      participantId,
      "participantId"
    );

    return this.getAnswerList()
      .filter(
        (answer) =>
          answer.participantId ===
          participantId
      );
  }

  /**
   * 全参加者の回答件数を取得する。
   *
   * @returns {number}
   */
  getAnswerCount() {
    return Object.keys(
      this.answers
    ).length;
  }

  /**
   * 現在の参加者の回答件数を取得する。
   *
   * @returns {number}
   */
  getCurrentParticipantAnswerCount() {
    return this
      .getCurrentParticipantAnswerList()
      .length;
  }

  /**
   * 現在の参加者の指定回答を削除する。
   *
   * @param {string} answerId
   * @returns {boolean}
   */
  removeAnswer(answerId) {
    this.validateId(
      answerId,
      "answerId"
    );

    const participantInfo =
      participant
        .getCurrentParticipant();

    return this
      .removeAnswerByParticipant(
        participantInfo.participantId,
        answerId
      );
  }

  /**
   * 参加者IDと回答IDを指定して削除する。
   *
   * @param {string} participantId
   * @param {string} answerId
   * @returns {boolean}
   */
  removeAnswerByParticipant(
    participantId,
    answerId
  ) {
    this.validateId(
      participantId,
      "participantId"
    );

    this.validateId(
      answerId,
      "answerId"
    );

    const storageKey =
      this.createStorageKey(
        participantId,
        answerId
      );

    if (!this.answers[storageKey]) {
      return false;
    }

    delete this.answers[storageKey];

    return true;
  }

  /**
   * 指定参加者の全回答を削除する。
   *
   * @param {string} participantId
   * @returns {number}
   */
  removeAnswersByParticipant(
    participantId
  ) {
    this.validateId(
      participantId,
      "participantId"
    );

    const keysToRemove =
      Object.keys(this.answers)
        .filter((storageKey) => {
          const answer =
            this.answers[storageKey];

          return (
            answer.participantId ===
            participantId
          );
        });

    keysToRemove.forEach(
      (storageKey) => {
        delete this.answers[
          storageKey
        ];
      }
    );

    return keysToRemove.length;
  }

  /**
   * 保存済みの回答一覧を復元する。
   *
   * 以前のanswerIdだけをキーにした保存形式も、
   * 新しい複合キー形式へ変換する。
   *
   * @param {Object} savedAnswers
   */
  restoreAnswers(savedAnswers) {
    if (
      !savedAnswers ||
      typeof savedAnswers !== "object" ||
      Array.isArray(savedAnswers)
    ) {
      throw new TypeError(
        "savedAnswers must be an object."
      );
    }

    const restoredAnswers = {};

    Object.values(savedAnswers)
      .forEach((savedAnswer) => {
        if (
          !savedAnswer ||
          typeof savedAnswer !==
            "object"
        ) {
          return;
        }

        const answerId =
          savedAnswer.answerId;

        if (
          typeof answerId !==
            "string" ||
          answerId.trim() === ""
        ) {
          return;
        }

        const participantId =
          typeof savedAnswer
            .participantId ===
            "string" &&
          savedAnswer
            .participantId
            .trim() !== ""
            ? savedAnswer
                .participantId
            : "DEFAULT";

        const storageKey =
          this.createStorageKey(
            participantId,
            answerId
          );

        restoredAnswers[
          storageKey
        ] = {
          ...structuredClone(
            savedAnswer
          ),
          participantId,
        };
      });

    this.answers =
      restoredAnswers;
  }

  /**
   * 全回答を初期化する。
   */
  clearAnswers() {
    this.answers = {};
  }

  /**
   * 参加者IDと回答IDから
   * 内部保存用のキーを作る。
   *
   * @param {string} participantId
   * @param {string} answerId
   * @returns {string}
   */
  createStorageKey(
    participantId,
    answerId
  ) {
    this.validateId(
      participantId,
      "participantId"
    );

    this.validateId(
      answerId,
      "answerId"
    );

    return (
      `${participantId}::` +
      `${answerId}`
    );
  }

  /**
   * IDが空文字でない文字列か確認する。
   *
   * @param {*} value
   * @param {string} name
   */
  validateId(value, name) {
    if (
      typeof value !== "string" ||
      value.trim() === ""
    ) {
      throw new TypeError(
        `${name} must be a non-empty string.`
      );
    }
  }
}

const answerStore =
  new AnswerStore();

export default answerStore;