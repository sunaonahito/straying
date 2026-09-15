/**
 * Research Novel Framework
 * Game State Manager
 *
 * 現在のプレイ、または現在の周回におけるゲーム状態を管理する。
 */

import config from "../core/config.js";
import eventBus from "../core/event-bus.js";
import { EventType } from "../core/types.js";
import participant from "../core/participant.js";

class StateManager {
  constructor() {
    this.state = this.createInitialState();
  }

  /**
   * 初期状態を生成する。
   *
   * @returns {Object}
   */
  createInitialState() {
    return {
      progress: {
        currentSceneId: null,
        currentRouteId: null,
        currentEndingId: null,
        lastSavePointId: null,
      },

      choices: {},
      textInputs: {},
      points: {},
      flags: {},
      variables: {},

      metadata: {
        stateVersion: config.VERSION,
        updatedAt: new Date().toISOString(),
      },
    };
  }

  /**
   * 現在の状態を取得する。
   *
   * @returns {Object}
   */
  getState() {
    return structuredClone(this.state);
  }

  /**
   * シーンIDを設定する。
   *
   * @param {string|null} sceneId
   */
  setCurrentScene(sceneId) {
    this.state.progress.currentSceneId = sceneId;
    this.touch();
  }

  /**
   * ルートIDを設定する。
   *
   * @param {string|null} routeId
   */
  setCurrentRoute(routeId) {
    this.state.progress.currentRouteId = routeId;
    this.touch();
  }

  /**
   * エンディングIDを設定する。
   *
   * @param {string|null} endingId
   */
  setCurrentEnding(endingId) {
    this.state.progress.currentEndingId = endingId;
    this.touch();
  }

  /**
   * 最後のセーブ地点を設定する。
   *
   * @param {string|null} savePointId
   */
  setLastSavePoint(savePointId) {
    this.state.progress.lastSavePointId = savePointId;
    this.touch();
  }

  /**
   * 現在の参加者の選択結果を保存する。
   *
   * @param {string} questionId
   * @param {string} choiceId
   * @param {string|null} choiceText
   */
  setChoice(
    questionId,
    choiceId,
    choiceText = null
  ) {
    this.validateId(
      questionId,
      "questionId"
    );

    this.validateId(
      choiceId,
      "choiceId"
    );

    if (
      choiceText !== null &&
      typeof choiceText !== "string"
    ) {
      throw new TypeError(
        "choiceText must be a string or null."
      );
    }

    const participantInfo =
      participant
        .getCurrentParticipant();

    const storageKey =
      this.createParticipantStorageKey(
        participantInfo.participantId,
        questionId
      );

    this.state.choices[storageKey] = {
      questionId,
      choiceId,
      choiceText,

      participantId:
        participantInfo.participantId,

      participantName:
        participantInfo.displayName,
    };

    this.touch();

    eventBus.emit(
      EventType.CHOICE_SELECTED,
      {
        questionId,
        choiceId,
        choiceText,
      }
    );
  }

  /**
   * 現在の参加者の自由入力を保存する。
   *
   * @param {string} inputId
   * @param {string} value
   */
  setTextInput(inputId, value) {
    this.validateId(
      inputId,
      "inputId"
    );

    if (typeof value !== "string") {
      throw new TypeError(
        "value must be a string."
      );
    }

    const participantInfo =
      participant
        .getCurrentParticipant();

    const storageKey =
      this.createParticipantStorageKey(
        participantInfo.participantId,
        inputId
      );

    this.state.textInputs[storageKey] = {
      inputId,
      value,

      participantId:
        participantInfo.participantId,

      participantName:
        participantInfo.displayName,
    };

    this.touch();

    eventBus.emit(
      EventType.TEXT_INPUT_SUBMITTED,
      {
        inputId,
        inputText: value,
      }
    );
  }

    /**
   * 現在の参加者の選択回答を削除する。
   *
   * @param {string} questionId
   * @returns {boolean}
   */
  removeChoice(questionId) {
    this.validateId(
      questionId,
      "questionId"
    );

    const participantInfo =
      participant
        .getCurrentParticipant();

    const storageKey =
      this.createParticipantStorageKey(
        participantInfo.participantId,
        questionId
      );

    if (
      !(storageKey in this.state.choices)
    ) {
      return false;
    }

    delete this.state.choices[
      storageKey
    ];

    this.touch();

    return true;
  }

    /**
   * 現在の参加者の自由入力回答を削除する。
   *
   * @param {string} inputId
   * @returns {boolean}
   */
  removeTextInput(inputId) {
    this.validateId(
      inputId,
      "inputId"
    );

    const participantInfo =
      participant
        .getCurrentParticipant();

    const storageKey =
      this.createParticipantStorageKey(
        participantInfo.participantId,
        inputId
      );

    if (
      !(
        storageKey in
        this.state.textInputs
      )
    ) {
      return false;
    }

    delete this.state.textInputs[
      storageKey
    ];

    this.touch();

    return true;
  }
  
  /**
 * 指定参加者に属する
 * Choice / Text InputをStateからすべて削除する。
 *
 * @param {string} participantId
 * @returns {{
 *   removedChoiceCount: number,
 *   removedTextInputCount: number
 * }}
 */
removeParticipantData(
  participantId
) {
  this.validateId(
    participantId,
    "participantId"
  );

  let removedChoiceCount = 0;
  let removedTextInputCount = 0;

  Object.keys(
    this.state.choices
  ).forEach((storageKey) => {
    const choice =
      this.state.choices[storageKey];

    const choiceParticipantId =
      choice?.participantId ??
      (
        storageKey.includes("::")
          ? storageKey.split("::")[0]
          : "DEFAULT"
      );

    if (
      choiceParticipantId ===
      participantId
    ) {
      delete this.state.choices[
        storageKey
      ];

      removedChoiceCount += 1;
    }
  });

  Object.keys(
    this.state.textInputs
  ).forEach((storageKey) => {
    const textInput =
      this.state.textInputs[
        storageKey
      ];

    const textParticipantId =
      textInput?.participantId ??
      (
        storageKey.includes("::")
          ? storageKey.split("::")[0]
          : "DEFAULT"
      );

    if (
      textParticipantId ===
      participantId
    ) {
      delete this.state.textInputs[
        storageKey
      ];

      removedTextInputCount += 1;
    }
  });

  if (
    removedChoiceCount > 0 ||
    removedTextInputCount > 0
  ) {
    this.touch();
  }

  return {
    removedChoiceCount,
    removedTextInputCount,
  };
}

    /**
   * 現在の参加者の選択回答を取得する。
   *
   * @param {string} questionId
   * @returns {Object|null}
   */
  getChoice(questionId) {
    this.validateId(
      questionId,
      "questionId"
    );

    const participantInfo =
      participant
        .getCurrentParticipant();

    const storageKey =
      this.createParticipantStorageKey(
        participantInfo.participantId,
        questionId
      );

    const choice =
      this.state.choices[storageKey];

    return choice
      ? structuredClone(choice)
      : null;
  }

  /**
   * 現在の参加者の自由入力回答を取得する。
   *
   * @param {string} inputId
   * @returns {Object|null}
   */
  getTextInput(inputId) {
    this.validateId(
      inputId,
      "inputId"
    );

    const participantInfo =
      participant
        .getCurrentParticipant();

    const storageKey =
      this.createParticipantStorageKey(
        participantInfo.participantId,
        inputId
      );

    const textInput =
      this.state.textInputs[
        storageKey
      ];

    return textInput
      ? structuredClone(textInput)
      : null;
  }

  /**
   * ポイントを設定する。
   *
   * @param {string} pointId
   * @param {number} value
   */
  setPoint(pointId, value) {
    this.validateId(pointId, "pointId");

    if (!Number.isFinite(value)) {
      throw new TypeError("value must be a finite number.");
    }

    this.state.points[pointId] = value;
    this.touch();
  }

  /**
   * ポイントを加算する。
   *
   * @param {string} pointId
   * @param {number} amount
   * @returns {number}
   */
  addPoint(pointId, amount) {
    this.validateId(pointId, "pointId");

    if (!Number.isFinite(amount)) {
      throw new TypeError("amount must be a finite number.");
    }

    const currentValue = this.state.points[pointId] ?? 0;
    const nextValue = currentValue + amount;

    this.state.points[pointId] = nextValue;
    this.touch();

    return nextValue;
  }

  /**
   * フラグを設定する。
   *
   * @param {string} flagId
   * @param {boolean} value
   */
  setFlag(flagId, value) {
    this.validateId(flagId, "flagId");

    if (typeof value !== "boolean") {
      throw new TypeError("value must be a boolean.");
    }

    this.state.flags[flagId] = value;
    this.touch();
  }

  /**
   * シナリオ変数を設定する。
   *
   * @param {string} variableId
   * @param {*} value
   */
  setVariable(variableId, value) {
    this.validateId(variableId, "variableId");

    this.state.variables[variableId] = value;
    this.touch();
  }

    /**
   * 保存済みのゲーム状態を復元する。
   *
   * @param {Object} savedState
   */
  restore(savedState) {
    if (
      !savedState ||
      typeof savedState !== "object" ||
      Array.isArray(savedState)
    ) {
      throw new TypeError(
        "savedState must be an object."
      );
    }

    const initialState =
      this.createInitialState();

    this.state = {
      ...initialState,
      ...structuredClone(savedState),

      progress: {
        ...initialState.progress,
        ...(savedState.progress ?? {}),
      },

            choices:
        this.restoreChoices(
          savedState.choices ?? {}
        ),

      textInputs:
        this.restoreTextInputs(
          savedState.textInputs ?? {}
        ),

      points: {
        ...(savedState.points ?? {}),
      },

      flags: {
        ...(savedState.flags ?? {}),
      },

      variables: {
        ...(savedState.variables ?? {}),
      },

      metadata: {
        ...initialState.metadata,
        ...(savedState.metadata ?? {}),
        updatedAt: new Date().toISOString(),
      },
    };
  }
  
    /**
   * 保存済みの選択回答を復元する。
   *
   * 旧形式の
   * Q001: "C001"
   * にも対応する。
   *
   * @param {Object} savedChoices
   * @returns {Object}
   */
  restoreChoices(savedChoices) {
    if (
      !savedChoices ||
      typeof savedChoices !== "object" ||
      Array.isArray(savedChoices)
    ) {
      return {};
    }

    const restoredChoices = {};

    Object.entries(savedChoices)
      .forEach(
        ([
          savedKey,
          savedChoice,
        ]) => {
          if (
            savedChoice &&
            typeof savedChoice ===
              "object" &&
            !Array.isArray(savedChoice)
          ) {
            const questionId =
              savedChoice.questionId ??
              savedKey.split("::")
                .at(-1);

            const participantId =
  savedChoice.participantId ??
  (
    savedKey.includes("::")
      ? savedKey.split("::")[0]
      : "DEFAULT"
  );

            const storageKey =
              this.createParticipantStorageKey(
                participantId,
                questionId
              );

            restoredChoices[
              storageKey
            ] = {
              ...structuredClone(
                savedChoice
              ),
              questionId,
              participantId,
            };

            return;
          }

          const storageKey =
            this.createParticipantStorageKey(
              "DEFAULT",
              savedKey
            );

          restoredChoices[
            storageKey
          ] = {
            questionId: savedKey,
            choiceId: savedChoice,
            choiceText: null,
            participantId:
              "DEFAULT",
            participantName:
              "プレイヤー",
          };
        }
      );

    return restoredChoices;
  }

  /**
   * 保存済みの自由入力回答を復元する。
   *
   * 旧形式の
   * I001: "回答内容"
   * にも対応する。
   *
   * @param {Object} savedTextInputs
   * @returns {Object}
   */
  restoreTextInputs(
    savedTextInputs
  ) {
    if (
      !savedTextInputs ||
      typeof savedTextInputs !==
        "object" ||
      Array.isArray(savedTextInputs)
    ) {
      return {};
    }

    const restoredTextInputs = {};

    Object.entries(savedTextInputs)
      .forEach(
        ([
          savedKey,
          savedTextInput,
        ]) => {
          if (
            savedTextInput &&
            typeof savedTextInput ===
              "object" &&
            !Array.isArray(
              savedTextInput
            )
          ) {
            const inputId =
              savedTextInput.inputId ??
              savedKey.split("::")
                .at(-1);

            const participantId =
              savedTextInput
                .participantId ??
              (savedKey.includes("::")
                ? savedKey.split("::")[0]
                : "DEFAULT");

            const storageKey =
              this.createParticipantStorageKey(
                participantId,
                inputId
              );

            restoredTextInputs[
              storageKey
            ] = {
              ...structuredClone(
                savedTextInput
              ),
              inputId,
              participantId,
            };

            return;
          }

          const storageKey =
            this.createParticipantStorageKey(
              "DEFAULT",
              savedKey
            );

          restoredTextInputs[
            storageKey
          ] = {
            inputId: savedKey,
            value: savedTextInput,
            participantId:
              "DEFAULT",
            participantName:
              "プレイヤー",
          };
        }
      );

    return restoredTextInputs;
  }
  
  /**
   * 現在の周回状態を初期化する。
   */
  reset() {
    this.state = this.createInitialState();
  }

  /**
   * 最終更新日時を更新する。
   */
  touch() {
    this.state.metadata.updatedAt = new Date().toISOString();
  }

    /**
   * 参加者IDと回答IDから
   * State内部用のキーを作る。
   *
   * @param {string} participantId
   * @param {string} answerId
   * @returns {string}
   */
  createParticipantStorageKey(
    participantId,
    answerId
  ) {
    this.validateId(
      participantId,
      "participantId"
    );

    this.validateId(
      answerId,
      "answerId"
    );

    return (
      `${participantId}::` +
      `${answerId}`
    );
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

const state = new StateManager();

export default state;