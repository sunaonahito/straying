/**
 * Research Novel Framework
 * Google Apps Script Receiver
 *
 * RNFから送信された研究データを受信し、
 * 指定されたスプレッドシートへ保存する。
 */

/**
 * 接続確認用。
 *
 * @returns {GoogleAppsScript.Content.TextOutput}
 */
function doGet() {
  return createJsonResponse({
    success: true,
    message: "RNF Research Receiver is running.",
  });
}

/**
 * RNFからのPOSTリクエストを受信する。
 *
 * @param {GoogleAppsScript.Events.DoPost} event
 * @returns {GoogleAppsScript.Content.TextOutput}
 */
function doPost(event) {
  try {
    if (!event || !event.postData || !event.postData.contents) {
      throw new Error("Request body is empty.");
    }

    const record = JSON.parse(event.postData.contents);

    validateRecord(record);

    const appended =
      appendRecord(record);

    return createJsonResponse({
      success: true,
      queueId: record.queueId,
      duplicate: !appended,
    });

  } catch (error) {
    console.error(error);

    return createJsonResponse({
      success: false,
      message: error.message,
    });
  }
}

/**
 * 未登録の受信データを
 * スプレッドシートへ追加する。
 *
 * 同じqueueIdが登録済みの場合は
 * 新しい行を追加しない。
 *
 * @param {Object} record
 * @returns {boolean}
 */
function appendRecord(record) {
  const lock =
    LockService.getScriptLock();

  lock.waitLock(10000);

  try {
    const spreadsheet =
      SpreadsheetApp.openById(
        RNF_RECEIVER_CONFIG
          .SPREADSHEET_ID
      );

    const sheet =
      spreadsheet.getSheetByName(
        RNF_RECEIVER_CONFIG
          .SHEET_NAME
      );

    if (!sheet) {
      throw new Error(
        `Sheet not found: ${
          RNF_RECEIVER_CONFIG
            .SHEET_NAME
        }`
      );
    }

    if (
      hasQueueId(
        sheet,
        record.queueId
      )
    ) {
      return false;
    }

    const payload = record.payload || {};

sheet.appendRow([
  new Date().toISOString(),
  record.queueId,
  record.recordType,
  record.queuedAt,
  record.status,
  JSON.stringify(payload),

  payload.studyId ?? "",
  payload.projectId ?? "",
  payload.siteId ?? "",
  payload.participantId ?? "",
  payload.playerId ?? "",
  payload.sessionId ?? "",

  payload.environment ?? "",
  payload.language ?? "",
  payload.scenarioVersion ?? "",
  payload.consentVersion ?? "",
  payload.frameworkVersion ?? "",

  payload.timestamp ??
    payload.answeredAt ??
    "",

  payload.sceneId ?? "",
  payload.routeId ?? "",

  payload.eventType ?? "",
  payload.answerId ?? "",
  payload.answerType ?? "",
  payload.value ?? "",
  payload.displayValue ?? "",
]);

    return true;
  } finally {
    lock.releaseLock();
  }
}

/**
 * queueIdが登録済みか確認する。
 *
 * queueIdはスプレッドシートの
 * B列に保存されている。
 *
 * @param {GoogleAppsScript.Spreadsheet.Sheet} sheet
 * @param {string} queueId
 * @returns {boolean}
 */
function hasQueueId(
  sheet,
  queueId
) {
  const lastRow =
    sheet.getLastRow();

  if (lastRow === 0) {
    return false;
  }

  const match =
    sheet
      .getRange(
        1,
        2,
        lastRow,
        1
      )
      .createTextFinder(
        String(queueId)
      )
      .matchEntireCell(true)
      .findNext();

  return match !== null;
}

/**
 * 受信データを検証する。
 *
 * @param {*} record
 */
function validateRecord(record) {
  if (!record || typeof record !== "object") {
    throw new Error("Record must be an object.");
  }

  const requiredFields = [
    "queueId",
    "recordType",
    "queuedAt",
    "status",
    "payload",
  ];

  requiredFields.forEach((field) => {
    if (record[field] === undefined || record[field] === null) {
      throw new Error(`Missing required field: ${field}`);
    }
  });
}

/**
 * JSONレスポンスを作成する。
 *
 * @param {Object} body
 * @returns {GoogleAppsScript.Content.TextOutput}
 */
function createJsonResponse(body) {
  return ContentService
    .createTextOutput(JSON.stringify(body))
    .setMimeType(ContentService.MimeType.JSON);
}