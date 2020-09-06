require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module DemoBlog
  class Application < Rails::Application
    config.load_defaults 6.0
    config.generators.system_tests                  = nil
    config.action_view.sanitized_allowed_attributes = ["href"]
    config.action_view.sanitized_allowed_tags       = [
      "a", "b", "br", "code", "em", "h2", "h3", "h4", "h5", "h6",
      "i", "li", "ol", "p", "s", "strong", "u", "ul", "section", "mark",
    ]
  end
end
