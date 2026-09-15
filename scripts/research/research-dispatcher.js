/**
 * Research Novel Framework
 * Research Dispatcher
 *
 * Research QueueのデータをTransportへ渡し、
 * 送信成功時のみQueueから削除する。
 *
 * 単発送信・一括送信・二重実行防止を担当する。
 */

import researchStorage from "./research-storage.js";
import httpTransport from "../transports/http-transport.js";

class ResearchDispatcher {
  constructor() {
    /**
     * 現在、送信処理が実行中かどうか。
     *
     * @type {boolean}
     */
    this.isDispatching = false;
  }

  /**
   * Queueの先頭にあるデータを実際に1件送信する。
   *
   * この内部処理では送信ロックを操作しない。
   * sendNext() と sendAll() から利用する。
   *
   * @returns {Promise<Object>}
   */
  async sendNextRecord() {
    const queue = researchStorage.getQueue();
    const record = queue[0];

    if (!record) {
      return {
        success: true,
        status: "empty",
        message: "送信待ちの研究データはありません。",
      };
    }

    const queueCountBefore =
      researchStorage.getQueueCount();

    const response = await httpTransport.send(record);

    if (
      response.queueId &&
      response.queueId !== record.queueId
    ) {
      throw new Error(
        "送信したqueueIdと受信側から返されたqueueIdが一致しません。"
      );
    }

    const removed = researchStorage.remove(
      record.queueId
    );

    if (!removed) {
      throw new Error(
        "送信には成功しましたが、Queueからデータを削除できませんでした。"
      );
    }

    return {
      success: true,
      status: "sent",
      queueId: record.queueId,
      recordType: record.recordType,
      queueCountBefore,
      queueCountAfter:
        researchStorage.getQueueCount(),
      response,
    };
  }

  /**
   * Queueの先頭にあるデータを1件送信する。
   *
   * 別の送信処理が動いている場合は開始しない。
   *
   * @returns {Promise<Object>}
   */
  async sendNext() {
    if (this.isDispatching) {
      return {
        success: false,
        status: "busy",
        message: "別の送信処理が実行中です。",
        remainingCount:
          researchStorage.getQueueCount(),
      };
    }

    this.isDispatching = true;

    try {
      return await this.sendNextRecord();
    } finally {
      this.isDispatching = false;
    }
  }

  /**
   * Queue内のデータを先頭から順番にすべて送信する。
   *
   * 途中で送信に失敗した場合は、その時点で停止する。
   * 失敗したデータと、それ以降のデータはQueueに残る。
   *
   * @returns {Promise<Object>}
   */
  async sendAll() {
    if (this.isDispatching) {
      return {
        success: false,
        status: "busy",
        sentCount: 0,
        remainingCount:
          researchStorage.getQueueCount(),
        message: "別の送信処理が実行中です。",
      };
    }

    this.isDispatching = true;

    const queueCountBefore =
      researchStorage.getQueueCount();

    if (queueCountBefore === 0) {
      this.isDispatching = false;

      return {
        success: true,
        status: "empty",
        sentCount: 0,
        remainingCount: 0,
        message: "送信待ちの研究データはありません。",
      };
    }

    let sentCount = 0;

    try {
      while (
        researchStorage.getQueueCount() > 0
      ) {
        const result =
          await this.sendNextRecord();

        if (result.status === "empty") {
          break;
        }

        sentCount += 1;

        console.log(
          `✅ ${sentCount}件目の送信に成功しました:`,
          result.queueId
        );
      }

      return {
        success: true,
        status: "completed",
        queueCountBefore,
        sentCount,
        remainingCount:
          researchStorage.getQueueCount(),
      };
    } catch (error) {
      return {
        success: false,
        status: "stopped",
        queueCountBefore,
        sentCount,
        remainingCount:
          researchStorage.getQueueCount(),
        message:
          "一括送信を途中で停止しました。",
        error,
      };
    } finally {
      this.isDispatching = false;
    }
  }

  /**
   * 現在の送信状態を取得する。
   *
   * @returns {Object}
   */
  getStatus() {
    return {
      isDispatching: this.isDispatching,
      queueCount:
        researchStorage.getQueueCount(),
    };
  }
}

const researchDispatcher =
  new ResearchDispatcher();

export default researchDispatcher;