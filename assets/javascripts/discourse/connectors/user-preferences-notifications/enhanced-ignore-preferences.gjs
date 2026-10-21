import Component from "@glimmer/component";
import { service } from "@ember/service";
import PreferenceCheckbox from "discourse/components/preference-checkbox";
import { i18n } from "discourse-i18n";

export default class EnhancedIgnorePreferences extends Component {
  @service siteSettings;

  <template>
    <div class="user-preferences-notifications-outlet enhanced-ignore-preferences">
      {{#if this.siteSettings.enhanced_ignore_enabled}}
        <fieldset class="enhanced-ignore">
          <div class="control-group enhanced-ignore">
            <label class="control-label">{{i18n
                "enhanced_ignore.enhanced_ignore"
              }}</label>

            <div class="controls">
              <PreferenceCheckbox
                @checked={{@model.custom_fields.hide_ignored_topics}}
                @labelKey="enhanced_ignore.hide_ignored_topics"
              />
              <PreferenceCheckbox
                @checked={{@model.custom_fields
                  .ignored_user_cannot_reply_to_me}}
                @labelKey="enhanced_ignore.ignored_user_cannot_reply_to_me"
              />
            </div>
          </div>
        </fieldset>
      {{/if}}
    </div>
  </template>
}
