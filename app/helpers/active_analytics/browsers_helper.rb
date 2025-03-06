module ActiveAnalytics
  module BrowsersHelper
    def browser_icon(browser_name)
      path = "browsers/#{browser_name.to_s.parameterize(separator: "_")}.svg"
      if AssetsController.endpoints.include?(path)
        image_tag(asset_url(path, host: request.host), alt: browser_name, class: "referer-favicon", width: 16, height: 16)
      else
        image_tag(asset_url("browsers/default.svg", host: request.host), alt: browser_name, class: "referer-favicon", width: 16, height: 16)
      end
    end
  end
end
