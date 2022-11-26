# frozen_string_literal: true

# name: enhanced-ignore
# about: enhanced plugin
# version: 0.2
# authors: Jiajun Du
# url: https://github.com/ShuiyuanSJTU/enhanced-ignore

enabled_site_setting :enhanced_ignore_enabled

PLUGIN_NAME ||= 'EnhancedIgnore'

after_initialize do

  DiscoursePluginRegistry.serialized_current_user_fields << 'hide_ignored_topics'
  DiscoursePluginRegistry.serialized_current_user_fields << 'ignored_user_cannot_reply_to_me'
  User.register_custom_field_type 'hide_ignored_topics', :boolean
  User.register_custom_field_type 'ignored_user_cannot_reply_to_me', :boolean
  register_editable_user_custom_field :hide_ignored_topics
  register_editable_user_custom_field :ignored_user_cannot_reply_to_me

   # TODO: 回复被屏蔽用户的主题不在时间线上提醒 PostAlerter, AboutController

   # 不在主题列表显示被屏蔽用户的帖子
   TopicQuery.add_custom_filter(:ignore_users) do |results, topic_query|
     if SiteSetting.enhanced_ignore_enabled?
       user = topic_query.user
        if user && user.custom_fields['hide_ignored_topics']
          ignored_user_ids = IgnoredUser.where(user: user).select(:ignored_user_id)
           results = results.where.not(user_id: ignored_user_ids)
        end
     end
      results
   end

   # 不让被屏蔽用户回复我
   module OverrideTopicGuardian
     def can_create_post_on_topic?(topic)
       return false if !super
       if SiteSetting.enhanced_ignore_enabled? && topic.user && topic.user.custom_fields['ignored_user_cannot_reply_to_me']
         ignored_user_ids = IgnoredUser.where(user: topic.user).select(:ignored_user_id)
         return !ignored_user_ids.exists?(ignored_user_id: @user)
       end
       true
     end
   end

   class ::Guardian
     prepend OverrideTopicGuardian
   end
end
