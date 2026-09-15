/**
 * Research Novel Framework
 * Research Storage
 *
 * 外部送信前の研究データをキューとして一時保存する。
 */

import config from "../core/config.js";

class ResearchStorage {
  constructor() {
    this.queue = this.loadQueue();
  }

  /**
   * Event Logを送信待ちキューへ追加する。
   *
   * @param {Object} eventLog
   * @returns {Object}
   */
  enqueueEvent(eventLog) {
    return this.enqueue({
      recordType: "event",
      payload: eventLog,
    });
  }

  /**
   * Answer Logを送信待ちキューへ追加する。
   *
   * @param {Object} answer
   * @returns {Object}
   */
  enqueueAnswer(answer) {
    return this.enqueue({
      recordType: "answer",
      payload: answer,
    });
  }

  /**
   * 研究データを共通形式でキューへ追加する。
   *
   * @param {Object} params
   * @param {string} params.recordType
   * @param {Object} params.payload
   * @returns {Object}
   */
  enqueue({ recordType, payload }) {
    if (typeof recordType !== "string" || recordType.trim() === "") {
      throw new TypeError("recordType must be a non-empty string.");
    }

    if (!payload || typeof payload !== "object") {
      throw new TypeError("payload must be an object.");
    }

    const record = {
      queueId: this.generateId(),
      recordType,
      queuedAt: new Date().toISOString(),
      status: "pending",
      retryCount: 0,
      payload: structuredClone(payload),
    };

    this.queue.push(record);
    this.persistQueue();

    if (config.DEBUG) {
      console.log("RNF Research Queue Added:", structuredClone(record));
    }

    return structuredClone(record);
  }

  /**
   * 送信待ちキューを取得する。
   *
   * @returns {Array}
   */
  getQueue() {
    return structuredClone(this.queue);
  }

  /**
   * 送信待ち件数を取得する。
   *
   * @returns {number}
   */
  getQueueCount() {
    return this.queue.length;
  }

  /**
   * 指定したレコードをキューから削除する。
   *
   * 送信成功後に使用する。
   *
   * @param {string} queueId
   * @returns {boolean}
   */
  remove(queueId) {
    const index = this.queue.findIndex(
      (record) => record.queueId === queueId
    );

    if (index === -1) {
      return false;
    }

    this.queue.splice(index, 1);
    this.persistQueue();

    return true;
  }

    /**
   * 現在のSession・参加者に属する
   * 指定回答の未送信レコードを削除する。
   *
   * Answer Logと、それに対応する
   * Event Logを対象とする。
   *
   * @param {Object} params
   * @param {string} params.sessionId
   * @param {string} params.participantId
   * @param {string[]} params.answerIds
   * @returns {{
   *   removedCount: number,
   *   remainingCount: number
   * }}
   */
  removeCurrentSessionAnswerRecords({
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
      typeof participantId !==
        "string" ||
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
          typeof answerId !==
            "string" ||
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
      this.queue.length;

    this.queue = this.queue.filter(
      (record) => {
        if (
          record.status !== "pending"
        ) {
          return true;
        }

        const payload =
          record.payload;

        if (
          !payload ||
          payload.sessionId !==
            sessionId
        ) {
          return true;
        }

        const payloadParticipantId =
          payload.participantId ??
          "DEFAULT";

        if (
          payloadParticipantId !==
            participantId
        ) {
          return true;
        }

        if (
          record.recordType ===
            "answer"
        ) {
          return !answerIdSet.has(
            payload.answerId
          );
        }

        if (
          record.recordType ===
            "event"
        ) {
          const eventAnswerId =
            payload.data?.questionId ??
            payload.data?.inputId ??
            null;

          return !answerIdSet.has(
            eventAnswerId
          );
        }

        return true;
      }
    );

    const removedCount =
      originalCount -
      this.queue.length;

    if (removedCount > 0) {
      this.persistQueue();
    }

    return {
      removedCount,
      remainingCount:
        this.queue.length,
    };
  }
  
  /**
 * 指定Session・参加者に属する
 * 未送信Research Queueをすべて削除する。
 *
 * Event Log / Answer Logの両方を対象とする。
 *
 * @param {Object} params
 * @param {string} params.sessionId
 * @param {string} params.participantId
 * @returns {{
 *   removedCount: number,
 *   remainingCount: number
 * }}
 */
/**
 * 指定参加者に属する
 * 未送信Research Queueをすべて削除する。
 *
 * Sessionを問わず、
 * Event Log / Answer Logの両方を対象とする。
 *
 * @param {string} participantId
 * @returns {{
 *   removedCount: number,
 *   remainingCount: number
 * }}
 */
removeRecordsByParticipant(
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

  const originalCount =
    this.queue.length;

  this.queue =
    this.queue.filter((record) => {
      if (
        record.status !== "pending"
      ) {
        return true;
      }

      const payload =
        record.payload;

      if (!payload) {
        return true;
      }

      const payloadParticipantId =
        payload.participantId ??
        "DEFAULT";

      return (
        payloadParticipantId !==
        participantId
      );
    });

  const removedCount =
    originalCount -
    this.queue.length;

  if (removedCount > 0) {
    this.persistQueue();
  }

  return {
    removedCount,
    remainingCount:
      this.queue.length,
  };
}



  /**
   * キューをすべて削除する。
   */
  clearQueue() {
    this.queue = [];
    this.persistQueue();
  }

  /**
   * Local Storageからキューを読み込む。
   *
   * @returns {Array}
   */
  loadQueue() {
    if (!config.STORAGE.RESEARCH_QUEUE.PERSIST) {
      return [];
    }

    const storageKey =
      config.STORAGE.RESEARCH_QUEUE.STORAGE_KEY;

    const savedQueue = localStorage.getItem(storageKey);

    if (!savedQueue) {
      return [];
    }

    try {
      const parsedQueue = JSON.parse(savedQueue);
      return Array.isArray(parsedQueue) ? parsedQueue : [];
    } catch (error) {
      console.error("Failed to load RNF research queue:", error);
      return [];
    }
  }

  /**
   * キューをLocal Storageへ保存する。
   */
  persistQueue() {
    if (!config.STORAGE.RESEARCH_QUEUE.PERSIST) {
      return;
    }

    const storageKey =
      config.STORAGE.RESEARCH_QUEUE.STORAGE_KEY;

    localStorage.setItem(
      storageKey,
      JSON.stringify(this.queue)
    );
  }

  /**
   * 一意なIDを生成する。
   *
   * @returns {string}
   */
  generateId() {
    if (
      typeof crypto !== "undefined" &&
      crypto.randomUUID
    ) {
      return crypto.randomUUID();
    }

    return `${Date.now()}-${Math.random()
      .toString(16)
      .slice(2)}`;
  }
}

const researchStorage = new ResearchStorage();

export default researchStorage;