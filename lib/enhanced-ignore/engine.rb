module EnhancedIgnore
  class Engine < ::Rails::Engine
    engine_name "EnhancedIgnore".freeze
    isolate_namespace EnhancedIgnore

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::EnhancedIgnore::Engine, at: "/enhanced-ignore"
      end
    end
  end
end
