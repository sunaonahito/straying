/**
 * Apps Script内部で受信処理を確認するテスト。
 */
function testAppendRecord() {
  const testEvent = {
    postData: {
      contents: JSON.stringify({
        queueId: "TEST-001",
        recordType: "event",
        queuedAt: new Date().toISOString(),
        status: "pending",
        payload: {
          eventType: "test:event",
          sceneId: "SC001",
          message: "RNF receiver test",
        },
      }),
    },
  };

  const response = doPost(testEvent);

  console.log(response.getContent());
}

/**
 * 同じqueueIdが再送された場合に、
 * 重複行が追加されないことを確認する。
 */
function testDuplicateQueueId() {
  const queueId =
    `TEST-DUPLICATE-${Date.now()}`;

  const testEvent = {
    postData: {
      contents: JSON.stringify({
        queueId,
        recordType: "event",
        queuedAt:
          new Date().toISOString(),
        status: "pending",
        payload: {
          eventType:
            "test:duplicate",
          sceneId: "SC_TEST",
          message:
            "RNF duplicate test",
        },
      }),
    },
  };

  const firstResponse =
    doPost(testEvent);

  const secondResponse =
    doPost(testEvent);

  const firstResult =
    JSON.parse(
      firstResponse.getContent()
    );

  const secondResult =
    JSON.parse(
      secondResponse.getContent()
    );

  console.log(
    "First response:",
    firstResult
  );

  console.log(
    "Second response:",
    secondResult
  );

  if (
    firstResult.success !== true ||
    firstResult.duplicate !== false
  ) {
    throw new Error(
      "First request should append a new row."
    );
  }

  if (
    secondResult.success !== true ||
    secondResult.duplicate !== true
  ) {
    throw new Error(
      "Second request should be treated as a duplicate."
    );
  }

  console.log(
    "✅ Duplicate queueId test passed:",
    queueId
  );
}