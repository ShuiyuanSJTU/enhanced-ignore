module EnhancedIgnore
  class EnhancedIgnoreController < ::ApplicationController
    requires_plugin EnhancedIgnore

    before_action :ensure_logged_in

    def index
    end
  end
end
