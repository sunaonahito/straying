/**
 * Research Novel Framework
 * Debug Utilities
 *
 * 開発中の確認表示をまとめて管理する。
 */

import config from "../core/config.js";

/**
 * 見出しを表示する。
 *
 * @param {string} title
 */
export function printTitle(title) {
  if (!config.DEBUG) return;

  console.log("");
  console.log(`========== ${title} ==========`);
}

/**
 * オブジェクトを表示する。
 *
 * @param {string} title
 * @param {*} object
 */
export function printObject(title, object) {
  if (!config.DEBUG) return;

  printTitle(title);
  console.log(structuredClone(object));
}

/**
 * 配列などを表形式で表示する。
 *
 * @param {string} title
 * @param {Array|Object} data
 */
export function printTable(title, data) {
  if (!config.DEBUG) return;

  printTitle(title);
  console.table(structuredClone(data));
}

/**
 * 区切り線を表示する。
 */
export function separator() {
  if (!config.DEBUG) return;

  console.log("────────────────────────────────────────");
}