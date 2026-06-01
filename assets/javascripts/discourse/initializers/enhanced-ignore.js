import { withPluginApi } from "discourse/lib/plugin-api";

function initializeEnhancedIgnore(api) {
  api.addSaveableCustomFields("notifications");
}

export default {
  name: "enhanced-ignore",

  initialize() {
    withPluginApi(initializeEnhancedIgnore);
  },
};
