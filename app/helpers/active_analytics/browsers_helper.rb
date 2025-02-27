module ActiveAnalytics
  module BrowsersHelper
    def browser_icon(browser_name)
      browser_name = browser_name.to_s.downcase.gsub(' ', '_')
      icon = "#{browser_name}.svg"
      
      if asset_exists?(icon)
        image_tag(asset_path(icon), alt: browser_name, class: "referer-favicon", width: 16, height: 16)
      else
        image_tag(asset_path("default_browser.svg"), alt: browser_name, class: "referer-favicon", width: 16, height: 16)
      end
    end

    private

    def asset_exists?(path)
      engine_root = ActiveAnalytics::Engine.root
      file_path = engine_root.join('app', 'views', 'active_analytics', 'assets', path)
      File.exist?(file_path)
    end
  end
end
