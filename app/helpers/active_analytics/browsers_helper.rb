module ActiveAnalytics
  module BrowsersHelper
    def browser_icon(browser_name)
      browser_name = browser_name.to_s.downcase.gsub(' ', '_')
      icon = "#{browser_name}.svg"
      
      if asset_exists?(icon)
        inline_svg(icon)
      else
        inline_svg("default_browser.svg")
      end
    end

    private

    def asset_exists?(path)
      engine_root = ActiveAnalytics::Engine.root
      file_path = engine_root.join('app', 'views', 'active_analytics', 'assets', path)
      File.exist?(file_path)
    end

    def inline_svg(filename)
      engine_root = ActiveAnalytics::Engine.root
      file_path = engine_root.join('app', 'views', 'active_analytics', 'assets', filename)
      svg_content = File.read(file_path)
      svg_content.sub!('<svg ', '<svg class="referer-favicon" width="16" height="16" ')
      svg_content.html_safe
    end
  end
end
