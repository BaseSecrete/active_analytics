module ActiveAnalytics
  module SitesHelper
    def site_icon(host)
      image_tag("https://icons.duckduckgo.com/ip3/#{host}.ico", referrerpolicy: "no-referrer", class: "referer-favicon")
    end
  end
end
