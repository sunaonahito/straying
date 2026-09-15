/**
 * Research Novel Framework
 * Participant Registry
 *
 * 端末内で参加者情報を継続的に管理する。
 */

class ParticipantRegistry {
  constructor() {
    this.storageKey = "rnf_participant_registry";
    this.participants = this.load();
  }

  /**
   * 名前に対応する参加者を取得する。
   * 未登録なら新しく作成する。
   *
   * @param {string} displayName
   * @returns {{
   *   participantId: string,
   *   displayName: string,
   *   createdAt: string
   * }}
   */
  getOrCreateByName(displayName) {
    if (
      typeof displayName !== "string" ||
      displayName.trim() === ""
    ) {
      throw new TypeError(
        "displayName must be a non-empty string."
      );
    }

    const normalizedName =
      this.normalizeName(displayName);

    const existing =
      this.participants.find(
        (participant) =>
          participant.normalizedName ===
          normalizedName
      );

    if (existing) {
      return structuredClone(existing);
    }

    const participant = {
      participantId: this.generateId(),
      displayName: displayName.trim(),
      normalizedName,
      createdAt: new Date().toISOString(),
    };

    this.participants.push(participant);
    this.persist();

    return structuredClone(participant);
  }

  /**
 * 氏名を入力せず匿名Participantを新規作成する。
 *
 * displayNameには個人名ではなく、
 * Participant IDから作った内部表示名を使用する。
 *
 * @returns {Object}
 */
createAnonymousParticipant() {
  const participantId =
    this.generateId();

  const shortId =
    participantId
      .replace(/-/g, "")
      .slice(0, 8)
      .toUpperCase();

  const displayName =
    `Participant ${shortId}`;

  const participant = {
    participantId,

    displayName,

    normalizedName:
      this.normalizeName(
        displayName
      ),

    createdAt:
      new Date().toISOString(),
  };

  this.participants.push(
    participant
  );

  this.persist();

  return structuredClone(
    participant
  );
}

  /**
   * 登録済み参加者一覧を取得する。
   *
   * @returns {Array}
   */
  getParticipants() {
    return structuredClone(
      this.participants
    );
  }

  /**
 * Participant IDから登録済み参加者を取得する。
 *
 * @param {string} participantId
 * @returns {Object|null}
 */
getById(participantId) {
  if (
    typeof participantId !== "string" ||
    participantId.trim() === ""
  ) {
    throw new TypeError(
      "participantId must be a non-empty string."
    );
  }

  const foundParticipant =
    this.participants.find(
      (participant) =>
        participant.participantId ===
        participantId
    );

  return foundParticipant
    ? structuredClone(foundParticipant)
    : null;
}

/**
 * Participant IDを指定して登録済み参加者を削除する。
 *
 * @param {string} participantId
 * @returns {boolean}
 */
removeById(participantId) {
  if (
    typeof participantId !== "string" ||
    participantId.trim() === ""
  ) {
    throw new TypeError(
      "participantId must be a non-empty string."
    );
  }

  const originalCount =
    this.participants.length;

  this.participants =
    this.participants.filter(
      (participant) =>
        participant.participantId !==
        participantId
    );

  const removed =
    this.participants.length <
    originalCount;

  if (removed) {
    this.persist();
  }

  return removed;
}

/**
 * 登録済み参加者をすべて削除する。
 *
 * @returns {number}
 */
clearParticipants() {
  const removedCount =
    this.participants.length;

  this.participants = [];

  this.persist();

  return removedCount;
}
  
  /**
   * 名前を比較用に整える。
   *
   * @param {string} displayName
   * @returns {string}
   */
  normalizeName(displayName) {
    return displayName
      .trim()
      .toLocaleLowerCase();
  }

  /**
   * Local Storageから読み込む。
   *
   * @returns {Array}
   */
  load() {
    const saved =
      localStorage.getItem(
        this.storageKey
      );

    if (!saved) {
      return [];
    }

    try {
      const parsed = JSON.parse(saved);

      return Array.isArray(parsed)
        ? parsed
        : [];
    } catch (error) {
      console.error(
        "Failed to load RNF participant registry:",
        error
      );

      return [];
    }
  }

  /**
   * Local Storageへ保存する。
   */
  persist() {
    localStorage.setItem(
      this.storageKey,
      JSON.stringify(
        this.participants
      )
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

    return (
      `${Date.now()}-` +
      Math.random()
        .toString(16)
        .slice(2)
    );
  }
}

const participantRegistry =
  new ParticipantRegistry();

export default participantRegistry;