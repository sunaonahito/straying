/**
 * Research Novel Framework
 * EventBus
 *
 * アプリケーション内のイベントを管理する
 */
class EventBus {
  constructor() {
    this.listeners = {};
  }

  /**
   * イベントを購読する
   * @param {string} eventName
   * @param {Function} callback
   */
  on(eventName, callback) {
    if (!this.listeners[eventName]) {
      this.listeners[eventName] = [];
    }

    this.listeners[eventName].push(callback);
  }

  /**
   * イベントを発行する
   * @param {string} eventName
   * @param {*} data
   */
  emit(eventName, data = {}) {
    const callbacks = this.listeners[eventName];

    if (!callbacks) return;

    callbacks.forEach(callback => callback(data));
  }
}

const eventBus = new EventBus();

export default eventBus;
