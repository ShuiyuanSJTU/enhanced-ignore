# frozen_string_literal: true

# name: enhanced-ignore
# about: enhanced plugin
# version: 0.1
# authors: dujiajun
# url: https://github.com/dujiajun/enhanced-ignore

DiscoursePluginRegistry.serialized_current_user_fields << 'enhanced_ignore'

register_asset 'stylesheets/common/enhanced-ignore.scss'
register_asset 'javascripts/discourse/templates/connectors/user-preferences-notifications/enhanced-ignore-preferences.hbs'
register_asset 'stylesheets/desktop/enhanced-ignore.scss', :desktop
register_asset 'stylesheets/mobile/enhanced-ignore.scss', :mobile

enabled_site_setting :enhanced_ignore_enabled

PLUGIN_NAME ||= 'EnhancedIgnore'

load File.expand_path('lib/enhanced-ignore/engine.rb', __dir__)

after_initialize do
  # https://github.com/discourse/discourse/blob/master/lib/plugin/instance.rb
  User.register_custom_field_type 'enhanced_ignore', :boolean
  register_editable_user_custom_field :enhanced_ignore

  if SiteSetting.enhanced_ignore_enabled?

    class ::TopicQuery
      module OverridingDefaultResults

        def default_results(options = {})

          if @user and @user.custom_fields['enhanced_ignore']
            results = super(options).where("topics.user_id NOT IN ( 
                                          SELECT ignored_user_id 
                                          FROM ignored_users 
                                          WHERE ignored_users.user_id = ?
                                          )", @user.id)
            results
          else
            super(options)
          end

        end
      end
      prepend OverridingDefaultResults
    end
    
    class ::Guardian
      module OverridingCanIgnoreUser

        def can_ignore_users?
          return false if anonymous?
          @user.staff? || @user.trust_level >= TrustLevel.levels[:basic]
        end

      end
      prepend OverridingCanIgnoreUser
    end

  end

end
