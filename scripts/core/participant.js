/**
 * Research Novel Framework
 * Participant Manager
 *
 * 現在のプレイで回答している参加者を管理する。
 */

class ParticipantManager {
  constructor() {
    this.currentParticipant =
      this.createDefaultParticipant();
  }

  /**
   * 初期参加者を生成する。
   *
   * 個人プレイでは、明示的な設定がなくても
   * DEFAULTとして記録できるようにする。
   *
   * @returns {{
   *   participantId: string,
   *   displayName: string
   * }}
   */
  createDefaultParticipant() {
    return {
      participantId: "DEFAULT",
      displayName: "プレイヤー",
    };
  }

  /**
   * 現在回答中の参加者を設定する。
   *
   * @param {Object} params
   * @param {string} params.participantId
   * @param {string} params.displayName
   * @returns {Object}
   */
  setCurrentParticipant({
    participantId,
    displayName,
  }) {
    this.validateId(
      participantId,
      "participantId"
    );

    if (
      typeof displayName !== "string" ||
      displayName.trim() === ""
    ) {
      throw new TypeError(
        "displayName must be a non-empty string."
      );
    }

    this.currentParticipant = {
      participantId:
        participantId.trim(),

      displayName:
        displayName.trim(),
    };

    return this.getCurrentParticipant();
  }

  /**
   * 現在回答中の参加者を取得する。
   *
   * @returns {Object}
   */
  getCurrentParticipant() {
    return structuredClone(
      this.currentParticipant
    );
  }

  /**
   * 初期参加者へ戻す。
   *
   * @returns {Object}
   */
  reset() {
    this.currentParticipant =
      this.createDefaultParticipant();

    return this.getCurrentParticipant();
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

const participant =
  new ParticipantManager();

export default participant;