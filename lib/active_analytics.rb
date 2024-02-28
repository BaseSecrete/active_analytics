require "browser"

require "active_analytics/version"
require "active_analytics/engine"

module ActiveAnalytics
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

  def self.user_agent_extractors
    @@user_agent_extractors ||= {
      browser: lambda do |b|
        return :firefox if b.firefox?
        return :chrome if b.chrome?
        return :edge if b.edge?
        return :safari if b.safari?
        ""
      end,
      device_type: lambda do |b|
        return :tablet if b.device.tablet?
        return :mobile if b.device.mobile?
        # No `desktop?` built in :(
        # https://github.com/fnando/browser/issues/297#issuecomment-294387382
        return :desktop if b.platform.windows? || b.platform.linux? || b.platform.mac?
        ""
      end,
      operating_system: lambda do |b|
        return :windows if b.platform.windows?
        return :android if b.platform.android?
        return :linux if b.platform.linux?
        return :ios if b.platform.ios?
        return :mac if b.platform.mac?
        ""
      end,
    }
  end

  def self.record_request(request)
    params = self.build_storable_hash(request)
    ViewsPerDay.append(params)
  rescue => ex
    if Rails.env.development? || Rails.env.test?
      raise ex
    else
      Rails.logger.error(ex.inspect)
      Rails.logger.error(ex.backtrace.join("\n"))
    end
  end

  QUEUE = "ActiveAnalytics::Queue"
  OLD_QUEUE = "ActiveAnalytics::OldQueue"

  def self.queue_request(request)
    params = self.build_storable_hash(request)
    key = Rack::Utils.build_nested_query(params)
    redis.hincrby(QUEUE, key.downcase, 1)
  end

  def self.flush_queue
    return if !redis.exists?(QUEUE)
    date = Date.today
    redis.rename(QUEUE, OLD_QUEUE)
    redis.hscan_each(OLD_QUEUE) do |key, count|
      args = Rack::Utils.parse_nested_query(key).symbolize_keys
      ViewsPerDay.append(**(args.merge(total: count)))
    end
    redis.del(OLD_QUEUE)
  end

  def self.build_storable_hash(request)
    params = {
      site: request.host,
      page: request.path,
      date: Date.today,
    }
    if request.referrer.present?
      params[:referrer_host], params[:referrer_path] = ViewsPerDay.split_referrer(request.referrer)
    end

    user_agent_columns = ViewsPerDay.user_agent_columns
    if user_agent_columns.any?
      browser = Browser.new(request.user_agent || "")
      user_agent_columns.each do |attribute|
        params[attribute] = self.user_agent_extractors[attribute].call(browser)
      end
    end

    params
  end
end
