require_dependency "enhanced_ignore_constraint"

EnhancedIgnore::Engine.routes.draw do
  get "/" => "enhanced_ignore#index", constraints: EnhancedIgnoreConstraint.new
  get "/actions" => "actions#index", constraints: EnhancedIgnoreConstraint.new
  get "/actions/:id" => "actions#show", constraints: EnhancedIgnoreConstraint.new
end
