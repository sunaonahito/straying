/**
 * Research Novel Framework
 * Withdrawal Code Manager
 */

import projectConfig from "../project/project-config.js";

class WithdrawalCodeManager {
  /**
   * 撤回コードを生成する。
   *
   * 例:
   * SOU-7K4P9X
   *
   * @returns {string|null}
   */
  generateCode() {
    const config =
      projectConfig.PARTICIPANT
        ?.WITHDRAWAL_CODE;

    if (!config?.ENABLED) {
      return null;
    }

    const prefix =
      config.PREFIX ?? "RNF";

    const length =
      config.LENGTH ?? 6;

    const characters =
      "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    let randomPart = "";

    for (
      let index = 0;
      index < length;
      index += 1
    ) {
      const randomIndex =
        Math.floor(
          Math.random() *
            characters.length
        );

      randomPart +=
        characters[randomIndex];
    }

    return `${prefix}-${randomPart}`;
  }
}

const withdrawalCodeManager =
  new WithdrawalCodeManager();

export default withdrawalCodeManager;