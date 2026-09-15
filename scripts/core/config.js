/**
 * Research Novel Framework
 * Configuration
 */

let RNF_LOCAL_CONFIG = {};

try {
  const localConfigModule =
    await import("./config.local.js");

  RNF_LOCAL_CONFIG =
    localConfigModule.default ?? {};
} catch (error) {
  console.warn(
    "[RNF] Local configuration was not loaded.",
    error
  );
}

const RNF_CONFIG = {
  VERSION: "0.1.0",
  DEBUG: true,

  ENVIRONMENT: "development",
  LANGUAGE: "ja",

  STUDY: {
    STUDY_ID: "US_PROTOTYPE_2026",
    SCENARIO_VERSION: "0.1.0",
    CONSENT_VERSION: "draft-1",
  },

  FEATURES: {
    MULTI_PARTICIPANT: false,
    SHOW_PREVIOUS_PLAY_ANSWERS: false,
    SHOW_CURRENT_PLAY_REFLECTION: true,
  },

PLAYER: {
  PERSIST_PLAYER_ID: true,
  STORAGE_KEY: "rnf_player_id",

  SESSION_STORAGE_KEY: "rnf_session_id",
  SESSION_START_TIME_STORAGE_KEY: "rnf_session_start_time",
},

STORAGE: {
  AUTO_SAVE: true,
  SEND_TO_SPREADSHEET: false,

  RESEARCH_QUEUE: {
    PERSIST: true,
    STORAGE_KEY: "rnf_research_queue",
  },

  PLAY_HISTORY: {
    PERSIST: true,
    STORAGE_KEY: "rnf_play_history",
    MAX_ENTRIES: 100,
  },
},

TRANSPORT: {
  ENABLED: Boolean(
    RNF_LOCAL_CONFIG.ENDPOINT_URL
  ),
  ENDPOINT_URL:
    RNF_LOCAL_CONFIG.ENDPOINT_URL ?? "",
  TIMEOUT_MS: 10000,
},

  LOG: {
    SAVE_EVENT_LOG: true,
    SAVE_ANSWER_LOG: true,
  },
};

export default RNF_CONFIG;