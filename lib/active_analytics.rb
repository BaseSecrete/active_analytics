require "active_analytics/version"
require "active_analytics/engine"

module ActiveAnalytics
  VERSION = "0.1.0"

  def self.record_request(request)
    params = {
      site: request.host,
      page: request.path,
      date: Date.today,
    }
    if request.referer.present?
      referer_uri = URI(request.referer)
      params[:referer_host] = referer_uri.host
      params[:referer_path] = referer_uri.path
    end
    ViewsPerDay.append(params)
  rescue => ex
    raise if Rails.env.development?
  end
end
