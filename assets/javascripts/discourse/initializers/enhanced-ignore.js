import { action } from "@ember/object";
import { withPluginApi } from "discourse/lib/plugin-api";


function initializeEnhancedIgnore(api) {
  api.modifyClass(
    "controller:preferences/notifications",
    (Superclass) =>
      class extends Superclass {
        @action
        save() {
          this.get("saveAttrNames").push("custom_fields");
          super.save();
        }
      }
  );
}

export default {
  name: "enhanced-ignore",

  initialize() {
    withPluginApi(initializeEnhancedIgnore);
  }
};
