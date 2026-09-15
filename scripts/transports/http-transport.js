/**
 * Research Novel Framework
 * HTTP Transport
 *
 * 研究データを設定されたHTTPエンドポイントへ送信する。
 */

import config from "../core/config.js";

class HttpTransport {
  /**
   * 研究データを1件送信する。
   *
   * @param {Object} record
   * @returns {Promise<Object>}
   */
  async send(record) {
    if (!config.TRANSPORT.ENABLED) {
      throw new Error("HTTP Transport is disabled.");
    }

    const endpointUrl = config.TRANSPORT.ENDPOINT_URL;

    if (
      typeof endpointUrl !== "string" ||
      endpointUrl.trim() === ""
    ) {
      throw new Error("Transport endpoint URL is not configured.");
    }

    if (!record || typeof record !== "object") {
      throw new TypeError("record must be an object.");
    }

    const controller = new AbortController();

    const timeoutId = setTimeout(() => {
      controller.abort();
    }, config.TRANSPORT.TIMEOUT_MS);

    try {
      const response = await fetch(endpointUrl, {
        method: "POST",

        // text/plainにすると、ブラウザの不要な
        // CORSプリフライトを避けやすくなる。
        headers: {
          "Content-Type": "text/plain;charset=utf-8",
        },

        body: JSON.stringify(record),
        signal: controller.signal,
      });

      if (!response.ok) {
        throw new Error(
          `HTTP request failed: ${response.status}`
        );
      }

      const responseBody = await response.json();

      if (!responseBody.success) {
        throw new Error(
          responseBody.message ||
            "The receiver returned an error."
        );
      }

      return responseBody;
    } catch (error) {
      if (error.name === "AbortError") {
        throw new Error("HTTP request timed out.");
      }

      throw error;
    } finally {
      clearTimeout(timeoutId);
    }
  }
}

const httpTransport = new HttpTransport();

export default httpTransport;