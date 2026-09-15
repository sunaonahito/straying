/**
 * Research Novel Framework
 * Research Event Listeners
 *
 * ゲームイベントを受け取り、
 * Event Log・Answer Store・ResearchStorageへ記録する。
 */

import eventBus from "../core/event-bus.js";
import { EventType } from "../core/types.js";
import logger from "./logger.js";
import answerStore from "./answer-store.js";
import researchStorage from "./research-storage.js";

let registered = false;

/**
 * 研究用イベントリスナーを登録する。
 */
export function registerResearchListeners() {
  if (registered) {
    return;
  }

  registered = true;

  eventBus.on(EventType.CHOICE_SELECTED, (data) => {
    const eventLog = logger.logEvent({
      eventType: EventType.CHOICE_SELECTED,
      data,
    });

    const answer = answerStore.saveChoice({
      questionId: data.questionId,
      choiceId: data.choiceId,
      choiceText: data.choiceText ?? null,
    });

    if (eventLog) {
      researchStorage.enqueueEvent(eventLog);
    }

    if (answer) {
      researchStorage.enqueueAnswer(answer);
    }
  });

  eventBus.on(EventType.TEXT_INPUT_SUBMITTED, (data) => {
    const eventLog = logger.logEvent({
      eventType: EventType.TEXT_INPUT_SUBMITTED,
      data,
    });

    const answer = answerStore.saveTextInput({
      inputId: data.inputId,
      inputText: data.inputText,
    });

    if (eventLog) {
      researchStorage.enqueueEvent(eventLog);
    }

    if (answer) {
      researchStorage.enqueueAnswer(answer);
    }
  });
}