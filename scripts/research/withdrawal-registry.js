/**
 * Research Novel Framework
 * Withdrawal Registry
 */

const STORAGE_KEY =
  "rnf_withdrawal_registry";

class WithdrawalRegistry {
  constructor() {
    this.records =
      this.loadRecords();
  }

  /**
   * Withdrawal CodeとParticipant IDの対応を登録する。
   *
   * @param {Object} params
   * @param {string} params.withdrawalCode
   * @param {string} params.participantId
   * @returns {Object}
   */
  register({
    withdrawalCode,
    participantId,
  }) {
    this.validateId(
      withdrawalCode,
      "withdrawalCode"
    );

    this.validateId(
      participantId,
      "participantId"
    );

    const existing =
      this.records.find(
        (record) =>
          record.participantId ===
          participantId
      );

    if (existing) {
      return structuredClone(
        existing
      );
    }

    const record = {
      withdrawalCode,
      participantId,
      createdAt:
        new Date().toISOString(),
    };

    this.records.push(record);

    this.persist();

    return structuredClone(record);
  }

  /**
   * Participant IDから撤回情報を取得する。
   *
   * @param {string} participantId
   * @returns {Object|null}
   */
  getByParticipantId(
    participantId
  ) {
    this.validateId(
      participantId,
      "participantId"
    );

    const found =
      this.records.find(
        (record) =>
          record.participantId ===
          participantId
      );

    return found
      ? structuredClone(found)
      : null;
  }

  /**
   * Withdrawal Codeから撤回情報を取得する。
   *
   * @param {string} withdrawalCode
   * @returns {Object|null}
   */
  getByWithdrawalCode(
    withdrawalCode
  ) {
    this.validateId(
      withdrawalCode,
      "withdrawalCode"
    );

    const found =
      this.records.find(
        (record) =>
          record.withdrawalCode ===
          withdrawalCode
      );

    return found
      ? structuredClone(found)
      : null;
  }

  /**
   * 登録内容をすべて取得する。
   *
   * @returns {Array}
   */
  getRecords() {
    return structuredClone(
      this.records
    );
  }

  /**
   * Participant IDを指定して削除する。
   *
   * @param {string} participantId
   * @returns {boolean}
   */
  removeByParticipantId(
    participantId
  ) {
    this.validateId(
      participantId,
      "participantId"
    );

    const originalCount =
      this.records.length;

    this.records =
      this.records.filter(
        (record) =>
          record.participantId !==
          participantId
      );

    const removed =
      this.records.length <
      originalCount;

    if (removed) {
      this.persist();
    }

    return removed;
  }

  /**
   * 全登録を削除する。
   *
   * @returns {number}
   */
  clear() {
    const removedCount =
      this.records.length;

    this.records = [];

    this.persist();

    return removedCount;
  }

  loadRecords() {
    const raw =
      localStorage.getItem(
        STORAGE_KEY
      );

    if (!raw) {
      return [];
    }

    try {
      const parsed =
        JSON.parse(raw);

      return Array.isArray(parsed)
        ? parsed
        : [];
    } catch (error) {
      console.error(
        "Failed to load withdrawal registry:",
        error
      );

      return [];
    }
  }

  persist() {
    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify(this.records)
    );
  }

  validateId(
    value,
    label
  ) {
    if (
      typeof value !== "string" ||
      value.trim() === ""
    ) {
      throw new TypeError(
        `${label} must be a non-empty string.`
      );
    }
  }
}

const withdrawalRegistry =
  new WithdrawalRegistry();

export default withdrawalRegistry;