require "active_analytics/version"
require "active_analytics/engine"

module ActiveAnalytics
  def self.redis_url=(string)
    @redis_url = string
  end

  def self.redis_url
    @redis_url ||= ENV["REDIS_URL"] || "redis://localhost"
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
  rescue => ex
    if Rails.env.development? || Rails.env.test?
      raise ex
    else
      Rails.logger.error(ex.inspect)
      Rails.logger.error(ex.backtrace.join("\n"))
    end
  end

  SEPARATOR = "|"
  QUEUE = "ActiveAnalytics::Queue"
  OLD_QUEUE = "ActiveAnalytics::OldQueue"

  def self.queue_request(request)
    keys = [request.host, request.path]
    if request.referrer.present?
      keys.concat(ViewsPerDay.split_referrer(request.referrer))
    end
    redis.hincrby(QUEUE, keys.join(SEPARATOR).downcase, 1)
  end

  def self.flush_queue
    return if !redis.exists?(QUEUE)
    cursor = 0
    date = Date.today
    redis.rename(QUEUE, OLD_QUEUE)
    redis.hscan_each(OLD_QUEUE) do |key, count|
      site, page, referrer_host, referrer_path = key.split(SEPARATOR)
      ViewsPerDay.append(date: date, site: site, page: page, referrer_host: referrer_host, referrer_path: referrer_path, total: count.to_i)
    end
    redis.del(OLD_QUEUE)
  end
end
