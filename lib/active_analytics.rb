require "active_analytics/version"
require "active_analytics/engine"
require "browser"

module ActiveAnalytics
  mattr_accessor :base_controller_class, default: "ActionController::Base"

  def self.redis_url=(string)
    @redis_url = string
  end

  def self.redis_url
    @redis_url ||= ENV["ACTIVE_ANALYTICS_REDIS_URL"] || ENV["REDIS_URL"] || "redis://localhost"
  end

  def self.redis=(connection)
    @redis = connection
  end

  def self.redis
    @redis ||= Redis.new(url: redis_url)
  end

  def self.record_request(request)
    params = {
      site: request.host,
      page: request.path,
      date: Date.today,
    }
    if request.referrer.present?
      params[:referrer_host], params[:referrer_path] = ViewsPerDay.split_referrer(request.referrer)
    end
    ViewsPerDay.append(params)

    browser = Browser.new(request.headers["User-Agent"])
    BrowsersPerDay.append(site: request.host, date: Date.today, name: browser.name, version: browser.version)
  rescue => ex
    if Rails.env.development? || Rails.env.test?
      raise ex
    else
      Rails.logger.error(ex.inspect)
      Rails.logger.error(ex.backtrace.join("\n"))
    end
  end

  SEPARATOR = "|"

  PAGE_QUEUE = "ActiveAnalytics::PageQueue"
  BROWSER_QUEUE = "ActiveAnalytics::BrowserQueue"

  OLD_PAGE_QUEUE = "ActiveAnalytics::OldPageQueue"
  OLD_BROWSER_QUEUE = "ActiveAnalytics::BrowserQueue"

  def self.queue_request(request)
    queue_request_page(request)
    queue_request_browser(request)
  end

  def self.queue_request_page(request)
    keys = [request.host, request.path]
    if request.referrer.present?
      keys.concat(ViewsPerDay.split_referrer(request.referrer))
    end
    redis.hincrby(PAGE_QUEUE, keys.join(SEPARATOR).downcase, 1)
  end

  def self.queue_request_browser(request)
    browser = Browser.new(request.headers["User-Agent"])
    keys = [request.host.downcase, browser.name, browser.version]
    redis.hincrby(BROWSER_QUEUE, keys.join(SEPARATOR), 1)
  end

  def self.flush_queue
    flush_page_queue
    flush_browser_queue
  end

  def self.flush_page_queue
    return if !redis.exists?(PAGE_QUEUE)
    date = Date.today
    redis.rename(PAGE_QUEUE, OLD_PAGE_QUEUE)
    redis.hscan_each(OLD_PAGE_QUEUE) do |key, count|
      site, page, referrer_host, referrer_path = key.split(SEPARATOR)
      ViewsPerDay.append(date: date, site: site, page: page, referrer_host: referrer_host, referrer_path: referrer_path, total: count.to_i)
    end
    redis.del(OLD_PAGE_QUEUE)
  end

  def self.flush_browser_queue
    return if !redis.exists?(BROWSER_QUEUE)
    date = Date.today
    redis.rename(BROWSER_QUEUE, OLD_BROWSER_QUEUE)
    redis.hscan_each(OLD_BROWSER_QUEUE) do |key, count|
      site, name, version = key.split(SEPARATOR)
      BrowsersPerDay.append(date: date, site: site, name: name, version: version, total: count.to_i)
    end
    redis.del(OLD_BROWSER_QUEUE)
  end
end
