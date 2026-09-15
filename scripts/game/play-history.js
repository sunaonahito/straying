/**
 * Research Novel Framework
 * Play History Manager
 *
 * 完了したプレイの参加者情報と
 * 回答スナップショットを端末内へ保存する。
 */

import config from "../core/config.js";
import player from "../core/player.js";
import participant from "../core/participant.js";
import sessionParticipants from "../core/session-participants.js";
import answerStore from "../research/answer-store.js";

class PlayHistoryManager {
  constructor() {
    this.history = this.loadHistory();
  }

  /**
   * 現在のプレイを完了履歴へ保存する。
   *
   * 同じSession IDが既に保存されている場合は、
   * 重複登録せず既存データを返す。
   *
   * @returns {Object}
   */
  saveCurrentPlay() {
    const sessionInfo =
      player.getSessionInfo();

    const currentParticipant =
      participant.getCurrentParticipant();

    const participants =
      sessionParticipants.getParticipants();

    const answers =
      answerStore.getAnswerList();

    const existingEntry =
      this.history.find(
        (entry) =>
          entry.sessionId ===
          sessionInfo.sessionId
      );

    if (existingEntry) {
      return {
        saved: false,
        reason: "duplicate_session",
        entry: structuredClone(
          existingEntry
        ),
      };
    }

    const entry = {
      playerId:
        sessionInfo.playerId,

      sessionId:
        sessionInfo.sessionId,

      /**
       * 複数人プレイ用の参加者一覧。
       */
      participants:
        structuredClone(participants),

      participantCount:
        participants.length,

      /**
       * 旧形式との互換性のため、
       * 完了時点の参加者情報も残す。
       */
      participantId:
        currentParticipant.participantId,

      participantName:
        currentParticipant.displayName,

      startedAt:
        sessionInfo.startTime,

      completedAt:
        new Date().toISOString(),

      answers:
        structuredClone(answers),
    };

    this.history.push(entry);

    this.trimHistory();
    this.persistHistory();

    return {
      saved: true,
      reason: "saved",
      entry: structuredClone(entry),
    };
  }

  /**
   * 全履歴を取得する。
   *
   * 古い順で返す。
   *
   * @returns {Array}
   */
  getHistory() {
    return structuredClone(
      this.history
    );
  }

  /**
   * 最新の完了プレイを取得する。
   *
   * @returns {Object|null}
   */
  getLatest() {
    if (this.history.length === 0) {
      return null;
    }

    return structuredClone(
      this.history[
        this.history.length - 1
      ]
    );
  }

  /**
   * 現在の参加者が、
   * 指定履歴へ参加しているか確認する。
   *
   * 新しい複数人形式と、
   * 以前の単独参加者形式の両方へ対応する。
   *
   * @param {Object} entry
   * @param {string} participantId
   * @returns {boolean}
   */
  historyContainsParticipant(
    entry,
    participantId
  ) {
    if (
      Array.isArray(entry.participants) &&
      entry.participants.some(
        (participantInfo) =>
          participantInfo.participantId ===
          participantId
      )
    ) {
      return true;
    }

    if (
      entry.participantId ===
      participantId
    ) {
      return true;
    }

    if (
      Array.isArray(entry.answers) &&
      entry.answers.some(
        (answer) =>
          answer.participantId ===
          participantId
      )
    ) {
      return true;
    }

    return false;
  }

  /**
   * 現在の参加者における、
   * 現在のSessionより前の最新プレイを取得する。
   *
   * @returns {Object|null}
   */
  getPreviousForCurrentParticipant() {
    const sessionInfo =
      player.getSessionInfo();

    const participantInfo =
      participant.getCurrentParticipant();

    const matchingHistory =
      this.history.filter((entry) => {
        if (
          entry.sessionId ===
          sessionInfo.sessionId
        ) {
          return false;
        }

        return this.historyContainsParticipant(
          entry,
          participantInfo.participantId
        );
      });

    if (
      matchingHistory.length === 0
    ) {
      return null;
    }

    return structuredClone(
      matchingHistory[
        matchingHistory.length - 1
      ]
    );
  }

  /**
   * 現在の参加者の前回プレイ回答を、
   * answerIdをキーとする形式で取得する。
   *
   * 複数人プレイ履歴では、
   * 現在の参加者の回答だけを抽出する。
   *
   * @returns {Object|null}
   */
  getPreviousAnswersForCurrentParticipant() {
    const previousPlay =
      this.getPreviousForCurrentParticipant();

    if (!previousPlay) {
      return null;
    }

    const participantInfo =
      participant.getCurrentParticipant();

    const previousAnswers =
      Array.isArray(previousPlay.answers)
        ? previousPlay.answers
        : [];

    const participantAnswers =
      previousAnswers.filter(
        (answer) => {
          const answerParticipantId =
            answer.participantId ??
            previousPlay.participantId ??
            "DEFAULT";

          return (
            answerParticipantId ===
            participantInfo.participantId
          );
        }
      );

    if (
      participantAnswers.length === 0
    ) {
      return null;
    }

    const answersById = {};

    participantAnswers.forEach(
      (answer) => {
        answersById[
          answer.answerId
        ] = structuredClone(answer);
      }
    );

    const savedParticipant =
      Array.isArray(
        previousPlay.participants
      )
        ? previousPlay.participants.find(
            (savedParticipantInfo) =>
              savedParticipantInfo
                .participantId ===
              participantInfo.participantId
          )
        : null;

    return {
      playerId:
        previousPlay.playerId,

      sessionId:
        previousPlay.sessionId,

      participantId:
        participantInfo.participantId,

      participantName:
        savedParticipant
          ?.displayName ??
        participantAnswers[0]
          ?.participantName ??
        previousPlay.participantName ??
        null,

      startedAt:
        previousPlay.startedAt,

      completedAt:
        previousPlay.completedAt,

      answers:
        answersById,
    };
  }

  /**
   * 最新から指定件数の履歴を取得する。
   *
   * @param {number} limit
   * @returns {Array}
   */
  getRecent(limit = 10) {
    if (
      !Number.isInteger(limit) ||
      limit <= 0
    ) {
      throw new TypeError(
        "limit must be a positive integer."
      );
    }

    return structuredClone(
      this.history.slice(-limit)
    );
  }

  /**
   * 履歴件数を取得する。
   *
   * @returns {number}
   */
  getCount() {
    return this.history.length;
  }

  /**
   * 指定Sessionの履歴を取得する。
   *
   * @param {string} sessionId
   * @returns {Object|null}
   */
  getBySessionId(sessionId) {
    this.validateId(
      sessionId,
      "sessionId"
    );

    const entry =
      this.history.find(
        (item) =>
          item.sessionId ===
          sessionId
      );

    return entry
      ? structuredClone(entry)
      : null;
  }

  /**
 * 指定参加者に関する情報を
 * Play Historyから削除する。
 *
 * 複数人プレイの場合は、
 * 他の参加者の履歴を残す。
 *
 * 対象参加者を除いた結果、
 * 参加者も回答も残らない履歴は削除する。
 *
 * @param {string} participantId
 * @returns {{
 *   affectedHistoryCount: number,
 *   removedHistoryCount: number,
 *   remainingHistoryCount: number
 * }}
 */
removeParticipantData(
  participantId
) {
  this.validateId(
    participantId,
    "participantId"
  );

  let affectedHistoryCount = 0;
  let removedHistoryCount = 0;

  const updatedHistory = [];

  this.history.forEach((entry) => {
    if (
      !this.historyContainsParticipant(
        entry,
        participantId
      )
    ) {
      updatedHistory.push(entry);
      return;
    }

    affectedHistoryCount += 1;

    const updatedEntry =
      structuredClone(entry);

    if (
      Array.isArray(
        updatedEntry.participants
      )
    ) {
      updatedEntry.participants =
        updatedEntry.participants.filter(
          (participantInfo) =>
            participantInfo
              .participantId !==
            participantId
        );

      updatedEntry.participantCount =
        updatedEntry.participants.length;
    }

    if (
      Array.isArray(
        updatedEntry.answers
      )
    ) {
      updatedEntry.answers =
        updatedEntry.answers.filter(
          (answer) => {
            const answerParticipantId =
              answer.participantId ??
              updatedEntry.participantId ??
              "DEFAULT";

            return (
              answerParticipantId !==
              participantId
            );
          }
        );
    }

    if (
      updatedEntry.participantId ===
      participantId
    ) {
      const replacementParticipant =
        Array.isArray(
          updatedEntry.participants
        )
          ? updatedEntry.participants[0]
          : null;

      if (replacementParticipant) {
        updatedEntry.participantId =
          replacementParticipant
            .participantId;

        updatedEntry.participantName =
          replacementParticipant
            .displayName;
      } else {
        updatedEntry.participantId =
          null;

        updatedEntry.participantName =
          null;
      }
    }

    const hasParticipants =
      Array.isArray(
        updatedEntry.participants
      ) &&
      updatedEntry.participants.length > 0;

    const hasAnswers =
      Array.isArray(
        updatedEntry.answers
      ) &&
      updatedEntry.answers.length > 0;

    if (
      !hasParticipants &&
      !hasAnswers
    ) {
      removedHistoryCount += 1;
      return;
    }

    updatedHistory.push(
      updatedEntry
    );
  });

  this.history =
    updatedHistory;

  if (
    affectedHistoryCount > 0
  ) {
    this.persistHistory();
  }

  return {
    affectedHistoryCount,
    removedHistoryCount,
    remainingHistoryCount:
      this.history.length,
  };
}

  /**
   * 全履歴を削除する。
   */
  clearHistory() {
    this.history = [];
    this.persistHistory();
  }

  /**
   * 保存上限を超えた古い履歴を削除する。
   */
  trimHistory() {
    const maxEntries =
      config.STORAGE
        .PLAY_HISTORY
        .MAX_ENTRIES;

    if (
      !Number.isInteger(maxEntries) ||
      maxEntries <= 0
    ) {
      return;
    }

    if (
      this.history.length >
      maxEntries
    ) {
      this.history =
        this.history.slice(
          -maxEntries
        );
    }
  }

  /**
   * Local Storageから履歴を読み込む。
   *
   * @returns {Array}
   */
  loadHistory() {
    const settings =
      config.STORAGE.PLAY_HISTORY;

    if (!settings?.PERSIST) {
      return [];
    }

    const savedHistory =
      localStorage.getItem(
        settings.STORAGE_KEY
      );

    if (!savedHistory) {
      return [];
    }

    try {
      const parsedHistory =
        JSON.parse(savedHistory);

      return Array.isArray(
        parsedHistory
      )
        ? parsedHistory
        : [];
    } catch (error) {
      console.error(
        "Failed to load RNF play history:",
        error
      );

      return [];
    }
  }

  /**
   * Local Storageへ履歴を保存する。
   */
  persistHistory() {
    const settings =
      config.STORAGE.PLAY_HISTORY;

    if (!settings?.PERSIST) {
      return;
    }

    localStorage.setItem(
      settings.STORAGE_KEY,
      JSON.stringify(this.history)
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

const playHistory =
  new PlayHistoryManager();

export default playHistory;