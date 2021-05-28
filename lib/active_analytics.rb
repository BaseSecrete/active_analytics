require "active_analytics/version"
require "active_analytics/engine"

module ActiveAnalytics
  def self.record_request(request)
    params = {
      site: request.host,
      page: request.path,
      date: Date.today,
    }
    if request.referrer.present?
      referrer_uri = URI(request.referrer)
      params[:referrer_host] = referrer_uri.host
      params[:referrer_path] = referrer_uri.path
    end
    ViewsPerDay.append(params)
  rescue => ex
    raise if Rails.env.development? || Rails.env.test?
  end
end
