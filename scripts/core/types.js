/**
 * Research Novel Framework
 * Shared Types and Constants
 */

/**
 * RNF内で使用するイベント名。
 *
 * イベント名は文字列を直接書かず、
 * 原則としてEventTypeを通して参照する。
 */
export const EventType = Object.freeze({
  GAME_START: "game:start",
  GAME_END: "game:end",

  SCENE_START: "scene:start",
  SCENE_END: "scene:end",

  ROUTE_ENTERED: "route:entered",
  ENDING_REACHED: "ending:reached",

  CHOICE_SELECTED: "choice:selected",
  TEXT_INPUT_SUBMITTED: "text-input:submitted",

  POINT_CHANGED: "point:changed",
  FLAG_CHANGED: "flag:changed",

  SAVE_COMPLETED: "save:completed",
  LOAD_COMPLETED: "load:completed",

  SESSION_INTERRUPTED: "session:interrupted",
});

/**
 * 研究ログの分類。
 */
export const LogType = Object.freeze({
  EVENT: "event",
  ANSWER: "answer",
});