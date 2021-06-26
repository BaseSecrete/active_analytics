module ActiveAnalytics
  class Engine < ::Rails::Engine
    isolate_namespace ActiveAnalytics

    initializer "active_analytics.assets.precompile" do |app|
      app.config.assets.precompile += %w[active_analytics/application.js active_analytics/application.css]
    end
  end
end
