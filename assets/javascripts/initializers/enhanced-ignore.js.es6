import { withPluginApi } from "discourse/lib/plugin-api";

function initializeEnhancedIgnore(api) {
  // https://github.com/discourse/discourse/blob/master/app/assets/javascripts/discourse/lib/plugin-api.js.es6
  api.modifyClass("controller:preferences/notifications", {
    pluginId: "enhanced-ignore",
    actions: {
      save() {
        this.get('saveAttrNames').push('custom_fields')
        this._super()
      }
    }
  })
}

export default {
  name: "enhanced-ignore",

  initialize() {
    withPluginApi("0.8.31", initializeEnhancedIgnore);
  }
};
