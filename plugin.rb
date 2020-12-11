# frozen_string_literal: true

# name: enhanced-ignore
# about: enhanced plugin
# version: 0.2
# authors: dujiajun
# url: https://github.com/dujiajun/enhanced-ignore

DiscoursePluginRegistry.serialized_current_user_fields << 'hide_ignored_topics'
DiscoursePluginRegistry.serialized_current_user_fields << 'hide_my_topics_to_ignored'

register_asset 'stylesheets/common/enhanced-ignore.scss'
register_asset 'javascripts/discourse/templates/connectors/user-preferences-notifications/enhanced-ignore-preferences.hbs'
register_asset 'stylesheets/desktop/enhanced-ignore.scss', :desktop
register_asset 'stylesheets/mobile/enhanced-ignore.scss', :mobile

enabled_site_setting :enhanced_ignore_enabled

PLUGIN_NAME ||= 'EnhancedIgnore'

load File.expand_path('lib/enhanced-ignore/engine.rb', __dir__)

after_initialize do
   # https://github.com/discourse/discourse/blob/master/lib/plugin/instance.rb
   User.register_custom_field_type 'hide_ignored_topics', :boolean
   User.register_custom_field_type 'hide_my_topics_to_ignored', :boolean
   register_editable_user_custom_field :hide_ignored_topics
   register_editable_user_custom_field :hide_my_topics_to_ignored

   if SiteSetting.enhanced_ignore_enabled?
      old = UserCustomField.where(name: 'enhanced_ignore')
      if old
         old.update_all(name: 'hide_ignored_topics')
      end
      class ::TopicQuery
         module OverridingDefaultResults

            def default_results(options = {})
               results = super(options)
               if @user and @user.custom_fields['hide_ignored_topics']
                  results = results.where("topics.user_id NOT IN (
                  SELECT ignored_user_id
                  FROM ignored_users
                  WHERE ignored_users.user_id = ?
                  )", @user.id)
               end
               if @user
                  results = results.where("? NOT IN
                  (
                  SELECT ignored_user_id
                  FROM ignored_users
                  WHERE ignored_users.user_id = topics.user_id
                  AND EXISTS (
                  SELECT user_id
                  FROM user_custom_fields
                  WHERE user_custom_fields.name = 'hide_my_topics_to_ignored'
                  AND user_custom_fields.value = 'true'
                  AND user_custom_fields.user_id = topics.user_id
                  )
                  )", @user.id)
               end
               results
            end
         end
         prepend OverridingDefaultResults
      end

      class ::Guardian
         module OverridingCanIgnoreUser

            def can_ignore_user?(target_user)
               can_ignore_users? && @user.id != target_user.id && !target_user.admin?
            end

         end
         prepend OverridingCanIgnoreUser
      end

      class ::TopicView
         module OverridingSetupFilteredPosts
            def setup_filtered_posts
               super()

          sql = <<~SQL
                SELECT ig.user_id
                FROM ignored_users as ig
                JOIN user_custom_fields as ucf ON ucf.user_id = ig.user_id
                WHERE ig.ignored_user_id = :current_user_id
                AND ucf.name = 'hide_my_topics_to_ignored' 
                AND ucf.value = 'true'
              SQL

          ignoring_user_ids = DB.query_single(sql, current_user_id: @user&.id)

          if ignoring_user_ids.present?
            @filtered_posts = @filtered_posts.where.not("user_id IN (?) AND id <> ?", ignoring_user_ids, first_post_id)
            @contains_gaps = true
          end
        end
      end
      prepend OverridingSetupFilteredPosts
    end

  end

end
