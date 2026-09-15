/**
 * Research Novel Framework
 * Session Participant Manager
 *
 * 1回のプレイセッションに参加する人の一覧と、
 * 現在回答中の参加者を管理する。
 */

import participant from "./participant.js";

class SessionParticipantManager {
  constructor() {
    this.participants = [];
    this.currentIndex = -1;
  }

  /**
   * セッション参加者を追加する。
   *
   * 同じParticipant IDは重複登録しない。
   *
   * @param {Object} participantInfo
   * @param {string} participantInfo.participantId
   * @param {string} participantInfo.displayName
   * @returns {Object}
   */

  addParticipant({
  participantId,
  displayName,
}) {
  this.validateParticipant({
    participantId,
    displayName,
  });

  const existingIndex =
    this.participants.findIndex(
      (item) =>
        item.participantId ===
        participantId
    );

  if (existingIndex !== -1) {
    return {
      added: false,
      reason: "duplicate_participant",
      participant: structuredClone(
        this.participants[
          existingIndex
        ]
      ),
      index: existingIndex,
    };
  }

  const newParticipant = {
    participantId:
      participantId.trim(),

    displayName:
      displayName.trim(),

    order:
      this.participants.length,

    addedAt:
      new Date().toISOString(),
  };

  this.participants.push(
    newParticipant
  );

  return {
    added: true,
    reason: "added",

    participant:
      structuredClone(
        newParticipant
      ),

    index:
      this.participants.length - 1,
  };
}

  /**
   * セッション参加者一覧を取得する。
   *
   * @returns {Array}
   */
  getParticipants() {
    return structuredClone(
      this.participants
    );
  }

  /**
   * セッション参加者数を取得する。
   *
   * @returns {number}
   */
  getParticipantCount() {
    return this.participants.length;
  }

  /**
   * Participant IDを指定して
   * 現在回答中の参加者へ切り替える。
   *
   * @param {string} participantId
   * @returns {Object}
   */
  selectById(participantId) {
    if (
      typeof participantId !== "string" ||
      participantId.trim() === ""
    ) {
      throw new TypeError(
        "participantId must be a non-empty string."
      );
    }

    const index =
      this.participants.findIndex(
        (item) =>
          item.participantId ===
          participantId
      );

    if (index === -1) {
      throw new Error(
        "Session participant was not found."
      );
    }

    return this.selectByIndex(index);
  }

  /**
   * 一覧上の番号を指定して
   * 現在回答中の参加者へ切り替える。
   *
   * 0から始まる番号を使用する。
   *
   * @param {number} index
   * @returns {Object}
   */
  selectByIndex(index) {
    if (
      !Number.isInteger(index) ||
      index < 0 ||
      index >= this.participants.length
    ) {
      throw new RangeError(
        "index is outside the session participant list."
      );
    }

    this.currentIndex = index;

    const selected =
      this.participants[index];

    participant.setCurrentParticipant({
      participantId:
        selected.participantId,

      displayName:
        selected.displayName,
    });

    return {
      currentIndex:
        this.currentIndex,

      participant:
        participant
          .getCurrentParticipant(),
    };
  }

  /**
   * 最初の参加者を現在回答中にする。
   *
   * @returns {Object|null}
   */
  selectFirst() {
    if (this.participants.length === 0) {
      return null;
    }

    return this.selectByIndex(0);
  }

  /**
   * 次の参加者へ切り替える。
   *
   * 最後の参加者まで回答済みの場合は、
   * completed: trueを返す。
   *
   * @returns {Object}
   */
  selectNext() {
    if (this.participants.length === 0) {
      return {
        completed: true,
        reason: "empty",
        currentIndex: -1,
        participant: null,
      };
    }

    const nextIndex =
      this.currentIndex + 1;

    if (
      nextIndex >=
      this.participants.length
    ) {
      return {
        completed: true,
        reason: "all_participants_completed",
        currentIndex:
          this.currentIndex,
        participant:
          participant
            .getCurrentParticipant(),
      };
    }

    const selection =
      this.selectByIndex(nextIndex);

    return {
      completed: false,
      reason: "selected",
      ...selection,
    };
  }

  /**
   * 現在のセッション参加状況を取得する。
   *
   * @returns {Object}
   */
  getStatus() {
    return {
      participantCount:
        this.participants.length,

      currentIndex:
        this.currentIndex,

      currentParticipant:
        this.currentIndex >= 0
          ? participant
              .getCurrentParticipant()
          : null,

      participants:
        this.getParticipants(),
    };
  }

  /**
 * Participant IDを指定して
 * Session参加者一覧から削除する。
 *
 * 現在回答中の参加者を削除した場合は、
 * 次の参加者、または直前の参加者へ切り替える。
 *
 * @param {string} participantId
 * @returns {{
 *   removed: boolean,
 *   removedParticipant: Object|null,
 *   currentIndex: number,
 *   currentParticipant: Object|null,
 *   participantCount: number
 * }}
 */
removeParticipantById(participantId) {
  if (
    typeof participantId !== "string" ||
    participantId.trim() === ""
  ) {
    throw new TypeError(
      "participantId must be a non-empty string."
    );
  }

  const index =
    this.participants.findIndex(
      (item) =>
        item.participantId ===
        participantId
    );

  if (index === -1) {
    return {
      removed: false,
      removedParticipant: null,
      currentIndex:
        this.currentIndex,
      currentParticipant:
        this.currentIndex >= 0
          ? participant
              .getCurrentParticipant()
          : null,
      participantCount:
        this.participants.length,
    };
  }

  const removedParticipant =
    structuredClone(
      this.participants[index]
    );

  this.participants.splice(
    index,
    1
  );

  /*
   * orderを振り直す。
   */
  this.participants =
    this.participants.map(
      (participantInfo, order) => ({
        ...participantInfo,
        order,
      })
    );

  /*
   * 全員いなくなった場合。
   */
  if (
    this.participants.length === 0
  ) {
    this.currentIndex = -1;
    participant.reset();

    return {
      removed: true,
      removedParticipant,
      currentIndex: -1,
      currentParticipant: null,
      participantCount: 0,
    };
  }

  /*
   * 現在位置より前の参加者を削除した場合、
   * currentIndexを1つ前へずらす。
   */
  if (
    index < this.currentIndex
  ) {
    this.currentIndex -= 1;

    const current =
      this.participants[
        this.currentIndex
      ];

    participant
      .setCurrentParticipant({
        participantId:
          current.participantId,
        displayName:
          current.displayName,
      });
  }

  /*
   * 現在回答中の参加者を削除した場合。
   *
   * 同じindexに次の参加者がいればその人、
   * いなければ最後の参加者を選ぶ。
   */
  else if (
    index === this.currentIndex
  ) {
    const nextIndex =
      Math.min(
        index,
        this.participants.length - 1
      );

    this.selectByIndex(
      nextIndex
    );
  }

  return {
    removed: true,
    removedParticipant,
    currentIndex:
      this.currentIndex,
    currentParticipant:
      this.currentIndex >= 0
        ? participant
            .getCurrentParticipant()
        : null,
    participantCount:
      this.participants.length,
  };
}

    /**
   * 保存済みのSession参加状況を復元する。
   *
   * @param {Object} savedStatus
   * @returns {Object}
   */
  restore(savedStatus) {
    if (
      !savedStatus ||
      typeof savedStatus !== "object" ||
      Array.isArray(savedStatus)
    ) {
      throw new TypeError(
        "savedStatus must be an object."
      );
    }

    const savedParticipants =
      savedStatus.participants;

    if (!Array.isArray(savedParticipants)) {
      throw new TypeError(
        "savedStatus.participants must be an array."
      );
    }

    this.participants =
      savedParticipants.map(
        (participantInfo, index) => {
          this.validateParticipant(
            participantInfo
          );

          return {
            participantId:
              participantInfo
                .participantId
                .trim(),

            displayName:
              participantInfo
                .displayName
                .trim(),

            order:
              Number.isInteger(
                participantInfo.order
              )
                ? participantInfo.order
                : index,

            addedAt:
              participantInfo.addedAt ??
              new Date().toISOString(),
          };
        }
      );

    const savedCurrentIndex =
      savedStatus.currentIndex;

    if (
      Number.isInteger(savedCurrentIndex) &&
      savedCurrentIndex >= 0 &&
      savedCurrentIndex <
        this.participants.length
    ) {
      this.selectByIndex(
        savedCurrentIndex
      );
    } else {
      this.currentIndex = -1;
      participant.reset();
    }

    return this.getStatus();
  }
  
  /**
   * セッション参加者を初期化する。
   */
  reset() {
    this.participants = [];
    this.currentIndex = -1;
    participant.reset();
  }

  /**
   * 参加者情報を検証する。
   *
   * @param {Object} participantInfo
   */
  validateParticipant({
    participantId,
    displayName,
  }) {
    if (
      typeof participantId !== "string" ||
      participantId.trim() === ""
    ) {
      throw new TypeError(
        "participantId must be a non-empty string."
      );
    }

    if (
      typeof displayName !== "string" ||
      displayName.trim() === ""
    ) {
      throw new TypeError(
        "displayName must be a non-empty string."
      );
    }
  }
}

const sessionParticipants =
  new SessionParticipantManager();

export default sessionParticipants;
