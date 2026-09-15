/**
 * Research Novel Framework
 * Consent Manager
 *
 * 研究参加への同意状態を、
 * Session IDとParticipant IDごとに管理する。
 *
 * 氏名やdisplayNameは保存しない。
 */

import config from "../core/config.js";
import player from "../core/player.js";
import participant from "../core/participant.js";

class ConsentManager {

  constructor() {
    this.storageKey = "rnf_consent_records";
    this.records = this.load();
  }

  /**
   * 現在の参加者について同意を記録する。
   *
   * @returns {Object}
   */
  recordConsent() {
    const sessionInfo =
      player.getSessionInfo();

    const participantInfo =
      participant.getCurrentParticipant();

    const record = {
      participantId:
        participantInfo.participantId,

      sessionId:
        sessionInfo.sessionId,

      consented: true,

      consentVersion:
        config.STUDY.CONSENT_VERSION,

      consentedAt:
        new Date().toISOString(),

      withdrawnAt: null,
    };

    const storageKey =
      this.createStorageKey(
        sessionInfo.sessionId,
        participantInfo.participantId
      );

    this.records[storageKey] =
      record;

    this.persist();

    if (config.DEBUG) {
      console.log(
        "RNF Consent Recorded:",
        structuredClone(record)
      );
    }

    return structuredClone(record);
  }

  /**
   * 現在の参加者の同意記録を取得する。
   *
   * @returns {Object|null}
   */
  getCurrentConsent() {
    const sessionInfo =
      player.getSessionInfo();

    const participantInfo =
      participant.getCurrentParticipant();

    const storageKey =
      this.createStorageKey(
        sessionInfo.sessionId,
        participantInfo.participantId
      );

    const record =
      this.records[storageKey];

    return record
      ? structuredClone(record)
      : null;
  }

  /**
   * 現在の参加者が有効な同意状態か確認する。
   *
   * 同意文書のVersionが現在の設定と
   * 一致する場合のみtrueとする。
   *
   * @returns {boolean}
   */
  hasCurrentConsent() {
    const record =
      this.getCurrentConsent();

    if (!record) {
      return false;
    }

    return (
      record.consented === true &&
      record.consentVersion ===
        config.STUDY.CONSENT_VERSION &&
      !record.withdrawnAt
    );
  }

  /**
   * 現在の参加者の同意を撤回する。
   *
   * 記録そのものは残し、
   * consentedをfalseに変更する。
   *
   * @returns {Object|null}
   */
  withdrawCurrentConsent() {
    const sessionInfo =
      player.getSessionInfo();

    const participantInfo =
      participant.getCurrentParticipant();

    const storageKey =
      this.createStorageKey(
        sessionInfo.sessionId,
        participantInfo.participantId
      );

    const record =
      this.records[storageKey];

    if (!record) {
      return null;
    }

    record.consented = false;
    record.withdrawnAt =
      new Date().toISOString();

    this.persist();

    return structuredClone(record);
  }

  /**
   * 現在の参加者の同意記録を削除する。
   *
   * @returns {boolean}
   */
  removeCurrentConsent() {
    const sessionInfo =
      player.getSessionInfo();

    const participantInfo =
      participant.getCurrentParticipant();

    const storageKey =
      this.createStorageKey(
        sessionInfo.sessionId,
        participantInfo.participantId
      );

    if (!this.records[storageKey]) {
      return false;
    }

    delete this.records[storageKey];

    this.persist();

    return true;
  }

  /**
   * 全同意記録を削除する。
   *
   * @returns {number}
   */
  clearConsentRecords() {
    const removedCount =
      Object.keys(this.records).length;

    this.records = {};

    this.persist();

    return removedCount;
  }

  /**
   * 全同意記録を取得する。
   *
   * @returns {Array}
   */
  getConsentRecords() {
    return Object.values(
      structuredClone(this.records)
    );
  }

  /**
   * Local Storageから読み込む。
   *
   * @returns {Object}
   */
  load() {
    const saved =
      localStorage.getItem(
        this.storageKey
      );

    if (!saved) {
      return {};
    }

    try {
      const parsed =
        JSON.parse(saved);

      return (
        parsed &&
        typeof parsed === "object" &&
        !Array.isArray(parsed)
      )
        ? parsed
        : {};

    } catch (error) {
      console.error(
        "Failed to load RNF consent records:",
        error
      );

      return {};
    }
  }

  /**
   * Local Storageへ保存する。
   */
  persist() {
    localStorage.setItem(
      this.storageKey,
      JSON.stringify(
        this.records
      )
    );
  }

  /**
   * Session IDとParticipant IDから
   * 内部保存用キーを作る。
   *
   * @param {string} sessionId
   * @param {string} participantId
   * @returns {string}
   */
  createStorageKey(
    sessionId,
    participantId
  ) {
    this.validateId(
      sessionId,
      "sessionId"
    );

    this.validateId(
      participantId,
      "participantId"
    );

    return (
      `${sessionId}::` +
      `${participantId}`
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

const consentManager =
  new ConsentManager();

export default consentManager;