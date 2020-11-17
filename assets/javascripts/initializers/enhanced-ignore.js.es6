import { withPluginApi } from "discourse/lib/plugin-api";
import { gte, or } from "@ember/object/computed";

function initializeEnhancedIgnore(api) {
  // https://github.com/discourse/discourse/blob/master/app/assets/javascripts/discourse/lib/plugin-api.js.es6
  api.modifyClass("controller:preferences/users",{
    userIsMemberOrAbove: gte("model.trust_level", 1),
    ignoredEnabled: or("userIsMemberOrAbove", "model.staff"),
  })

  api.modifyClass("controller:preferences/notifications",{
    actions: {
      save () {
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
