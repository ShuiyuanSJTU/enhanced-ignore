class EnhancedIgnoreConstraint
  def matches?(request)
    SiteSetting.enhanced_ignore_enabled
  end
end
