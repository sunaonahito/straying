/**
 * Research Novel Framework
 * Progress Manager
 *
 * 周回やセッションをまたいで保持する、
 * プレイヤーの長期的な進行状況を管理する。
 */

import config from "../core/config.js";

class ProgressManager {
  constructor() {
    this.progress = this.createInitialProgress();
  }

  /**
   * 初期進行データを生成する。
   *
   * @returns {Object}
   */
  createInitialProgress() {
    const now = new Date().toISOString();

    return {
      playCount: 0,
      accessCount: 0,

      firstAccessAt: now,
      lastAccessAt: now,

      completedRoutes: [],
      unlockedEndings: [],
      unlockedGalleryItems: [],

      lifetimePoints: {},
      inventory: {},
      achievements: [],

      routeHistory: [],

      metadata: {
        progressVersion: config.VERSION,
        updatedAt: now,
      },
    };
  }

  /**
   * 現在の進行データを取得する。
   *
   * @returns {Object}
   */
  getProgress() {
    return structuredClone(this.progress);
  }

  /**
   * アクセス回数を加算する。
   *
   * @returns {number}
   */
  recordAccess() {
    this.progress.accessCount += 1;
    this.progress.lastAccessAt = new Date().toISOString();
    this.touch();

    return this.progress.accessCount;
  }

  /**
   * プレイ回数を加算する。
   *
   * @returns {number}
   */
  incrementPlayCount() {
    this.progress.playCount += 1;
    this.touch();

    return this.progress.playCount;
  }

  /**
   * 完了済みルートを追加する。
   *
   * @param {string} routeId
   */
  completeRoute(routeId) {
    this.validateId(routeId, "routeId");
    this.addUnique(this.progress.completedRoutes, routeId);
    this.touch();
  }

  /**
   * エンディングを解放する。
   *
   * @param {string} endingId
   */
  unlockEnding(endingId) {
    this.validateId(endingId, "endingId");
    this.addUnique(this.progress.unlockedEndings, endingId);
    this.touch();
  }

  /**
   * ギャラリー項目を解放する。
   *
   * @param {string} galleryItemId
   */
  unlockGalleryItem(galleryItemId) {
    this.validateId(galleryItemId, "galleryItemId");
    this.addUnique(this.progress.unlockedGalleryItems, galleryItemId);
    this.touch();
  }

  /**
   * 永続ポイントを設定する。
   *
   * @param {string} pointId
   * @param {number} value
   */
  setLifetimePoint(pointId, value) {
    this.validateId(pointId, "pointId");

    if (!Number.isFinite(value)) {
      throw new TypeError("value must be a finite number.");
    }

    this.progress.lifetimePoints[pointId] = value;
    this.touch();
  }

  /**
   * 永続ポイントを加算する。
   *
   * @param {string} pointId
   * @param {number} amount
   * @returns {number}
   */
  addLifetimePoint(pointId, amount) {
    this.validateId(pointId, "pointId");

    if (!Number.isFinite(amount)) {
      throw new TypeError("amount must be a finite number.");
    }

    const currentValue = this.progress.lifetimePoints[pointId] ?? 0;
    const nextValue = currentValue + amount;

    this.progress.lifetimePoints[pointId] = nextValue;
    this.touch();

    return nextValue;
  }

  /**
   * アイテム数を設定する。
   *
   * @param {string} itemId
   * @param {number} quantity
   */
  setItemQuantity(itemId, quantity) {
    this.validateId(itemId, "itemId");

    if (!Number.isInteger(quantity) || quantity < 0) {
      throw new TypeError("quantity must be a non-negative integer.");
    }

    this.progress.inventory[itemId] = quantity;
    this.touch();
  }

  /**
   * アイテムを追加する。
   *
   * @param {string} itemId
   * @param {number} quantity
   * @returns {number}
   */
  addItem(itemId, quantity = 1) {
    this.validateId(itemId, "itemId");

    if (!Number.isInteger(quantity) || quantity <= 0) {
      throw new TypeError("quantity must be a positive integer.");
    }

    const currentQuantity = this.progress.inventory[itemId] ?? 0;
    const nextQuantity = currentQuantity + quantity;

    this.progress.inventory[itemId] = nextQuantity;
    this.touch();

    return nextQuantity;
  }

  /**
   * 実績を解放する。
   *
   * @param {string} achievementId
   */
  unlockAchievement(achievementId) {
    this.validateId(achievementId, "achievementId");
    this.addUnique(this.progress.achievements, achievementId);
    this.touch();
  }

  /**
   * ルート完了履歴を記録する。
   *
   * @param {Object} params
   * @param {string} params.routeId
   * @param {string} params.endingId
   */
  addRouteHistory({ routeId, endingId }) {
    this.validateId(routeId, "routeId");
    this.validateId(endingId, "endingId");

    this.progress.routeHistory.push({
      routeId,
      endingId,
      completedAt: new Date().toISOString(),
    });

    this.touch();
  }

  /**
   * 進行データを初期状態へ戻す。
   */
  reset() {
    this.progress = this.createInitialProgress();
  }

  /**
   * 最終更新日時を更新する。
   */
  touch() {
    this.progress.metadata.updatedAt = new Date().toISOString();
  }

  /**
   * 配列へ重複なしで値を追加する。
   *
   * @param {Array} list
   * @param {*} value
   */
  addUnique(list, value) {
    if (!list.includes(value)) {
      list.push(value);
    }
  }

  /**
   * IDが空文字でない文字列か確認する。
   *
   * @param {*} value
   * @param {string} name
   */
  validateId(value, name) {
    if (typeof value !== "string" || value.trim() === "") {
      throw new TypeError(`${name} must be a non-empty string.`);
    }
  }
}

const progress = new ProgressManager();

export default progress;