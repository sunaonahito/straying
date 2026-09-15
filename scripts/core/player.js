/**
 * Research Novel Framework
 * Player Manager
 *
 * 匿名プレイヤーIDとプレイセッションを管理する。
 */

import config from "./config.js";

class PlayerManager {
  constructor() {
    this.playerId = null;
    this.sessionId = null;
    this.startTime = null;
  }

  /**
   * プレイヤー情報を初期化する。
   *
   * playerId:
   * 同じブラウザで継続して利用する匿名ID。
   *
   * sessionId:
   * 通常の再読み込みでは維持される。
   * 新しいプレイ開始時のみ新しく発行する。
   *
   * @returns {{
   *   playerId: string,
   *   sessionId: string,
   *   startTime: string
   * }}
   */
  initialize() {
    this.playerId = this.getOrCreatePlayerId();

    const sessionInfo =
      this.getOrCreateSession();

    this.sessionId = sessionInfo.sessionId;
    this.startTime = sessionInfo.startTime;

    return this.getSessionInfo();
  }

  /**
   * 保存済みのプレイヤーIDを取得する。
   * 保存されていなければ新しく作成する。
   *
   * @returns {string}
   */
  getOrCreatePlayerId() {
    const shouldPersist =
      config.PLAYER.PERSIST_PLAYER_ID;

    if (!shouldPersist) {
      return this.generateId();
    }

    const storageKey =
      config.PLAYER.STORAGE_KEY;

    const savedPlayerId =
      localStorage.getItem(storageKey);

    if (savedPlayerId) {
      return savedPlayerId;
    }

    const newPlayerId =
      this.generateId();

    localStorage.setItem(
      storageKey,
      newPlayerId
    );

    return newPlayerId;
  }

  /**
   * 保存済みのセッション情報を取得する。
   * 保存されていなければ新しく作成する。
   *
   * @returns {{
   *   sessionId: string,
   *   startTime: string
   * }}
   */
  getOrCreateSession() {
    const sessionIdKey =
      config.PLAYER.SESSION_STORAGE_KEY;

    const startTimeKey =
      config.PLAYER
        .SESSION_START_TIME_STORAGE_KEY;

    const savedSessionId =
      localStorage.getItem(sessionIdKey);

    const savedStartTime =
      localStorage.getItem(startTimeKey);

    if (
      savedSessionId &&
      savedStartTime
    ) {
      return {
        sessionId: savedSessionId,
        startTime: savedStartTime,
      };
    }

    return this.createAndSaveSession();
  }

  /**
   * 新しいプレイセッションを開始する。
   *
   * Player IDは維持し、
   * Session IDとStart Timeだけを更新する。
   *
   * @returns {{
   *   playerId: string|null,
   *   sessionId: string,
   *   startTime: string
   * }}
   */
  startNewSession() {
    const newSession =
      this.createAndSaveSession();

    this.sessionId =
      newSession.sessionId;

    this.startTime =
      newSession.startTime;

    console.log(
      "✅ New RNF session started:",
      this.getSessionInfo()
    );

    return this.getSessionInfo();
  }

  /**
   * 新しいセッション情報を作成して保存する。
   *
   * @returns {{
   *   sessionId: string,
   *   startTime: string
   * }}
   */
  createAndSaveSession() {
    const sessionId =
      this.generateId();

    const startTime =
      new Date().toISOString();

    localStorage.setItem(
      config.PLAYER.SESSION_STORAGE_KEY,
      sessionId
    );

    localStorage.setItem(
      config.PLAYER
        .SESSION_START_TIME_STORAGE_KEY,
      startTime
    );

    return {
      sessionId,
      startTime,
    };
  }

  /**
   * 現在のセッション情報を返す。
   *
   * @returns {{
   *   playerId: string|null,
   *   sessionId: string|null,
   *   startTime: string|null
   * }}
   */
  getSessionInfo() {
    return {
      playerId: this.playerId,
      sessionId: this.sessionId,
      startTime: this.startTime,
    };
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
      `${Math.random()
        .toString(16)
        .slice(2)}`
    );
  }
}

const player = new PlayerManager();

export default player;