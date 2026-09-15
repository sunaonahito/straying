/**
 * Research Novel Framework
 * Project Configuration
 *
 * Straying
 * Southern Oregon University test
 */

const STRAYING_SOU_CONFIG = {
  PROJECT_ID: "STRAYING_SOU_2026",

  TITLE: "Straying",
  SITE_ID: "SOU",
  LANGUAGE: "en",

  SCENARIO_VERSION: "0.1.0",

  INITIAL_STATE: {
    SCENE_ID: "SC_STRAYING_ENTRY",
    ROUTE_ID: "ROUTE_STRAYING_MAIN",
  },

SCENES: {
  S000: "S000",
  S001: "S001",
  S002: "S002",
  S003: "S003",
  S004: "S004",
  S005: "S005",
  S006: "S006",
  S007: "S007",
  S008: "S008",
  S009: "S009",
  S010: "S010",
  S011: "S011",
},

  ROUTES: {
  R001: "R001",
},

ANSWERS: {
  Q001: {
    QUESTION_ID: "Q001",

    CHOICES: {
      C01: "Q001_C01",
      C02: "Q001_C02",
    },
  },

  Q002: {
    QUESTION_ID: "Q002",

    CHOICES: {
      C01: "Q002_C01",
      C02: "Q002_C02",
    },
  },

  Q003: {
    QUESTION_ID: "Q003",

    CHOICES: {
        C01: "Q003_C01",
        C02: "Q003_C02",
    },
},

Q004: {
    QUESTION_ID: "Q004",

    CHOICES: {
        C01: "Q004_C01",
        C02: "Q004_C02",
    },
},

Q005: {
    QUESTION_ID: "Q005",

    CHOICES: {
        C01: "Q005_C01",
        C02: "Q005_C02",
        C03: "Q005_C03",
    },
},

Q006: {
    QUESTION_ID: "Q006",

    CHOICES: {
        C01: "Q006_C01",
        C02: "Q006_C02",
    },
},

  I001_1: {
    INPUT_ID: "I001_1",
},

I001_2: {
    INPUT_ID: "I001_2",
},

I001_3: {
    INPUT_ID: "I001_3",
  },
},

GAME_INPUTS: {
  G001: {
    INPUT_ID: "G001",
  },
},

  PARTICIPANT: {
  WITHDRAWAL_CODE: {
    ENABLED: true,
    PREFIX: "SOU",
    LENGTH: 6,
  },
},
};

export default STRAYING_SOU_CONFIG;