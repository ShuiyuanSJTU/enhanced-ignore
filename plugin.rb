# frozen_string_literal: true

# name: enhanced-ignore
# about: enhanced plugin
# version: 0.2
# authors: Jiajun Du
# url: https://github.com/ShuiyuanSJTU/enhanced-ignore

DiscoursePluginRegistry.serialized_current_user_fields << 'hide_ignored_topics'

register_asset 'javascripts/discourse/templates/connectors/user-preferences-notifications/enhanced-ignore-preferences.hbs'

enabled_site_setting :enhanced_ignore_enabled

PLUGIN_NAME ||= 'EnhancedIgnore'

after_initialize do

   User.register_custom_field_type 'hide_ignored_topics', :boolean
   register_editable_user_custom_field :hide_ignored_topics

   # TODO: 回复被屏蔽用户的主题不在时间线上提醒 PostAlerter, AboutController
   # TODO: 不显示回复被屏蔽用户的帖子 TopicView
   TopicQuery.add_custom_filter(:ignore_users) do |results, topic_query|
      if SiteSetting.enhanced_ignore_enabled?
         user = topic_query.user
         if user and user.custom_fields['hide_ignored_topics']
            ignored_user_ids = IgnoredUser.where(user: user).select(:ignored_user_id)
            results = results.where.not(user_id: ignored_user_ids)
         end
      end
      results
   end
   

end
