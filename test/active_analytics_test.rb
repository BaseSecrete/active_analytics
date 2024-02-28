require "test_helper"
require "redis"

class ActiveAnalyticsTest < ActiveSupport::TestCase
  Request = Struct.new(:host, :path, :referrer, :user_agent)

  def test_record_request_with_identical
    req = Request.new("site.test", "page", "http://site.test")

    assert_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req) }
    assert_no_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req) }
  end

  def test_record_request_with_referrer
    req1, req2, req3, req4 = sample_requests

    assert_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req1) }
    assert_no_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req2) }
    assert_equal(2, ActiveAnalytics::ViewsPerDay.last.total)
    assert_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req3) }
    assert_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req4) }
  end

  def test_record_request_without_referrer
    req1 = Request.new("SITE.TEST", "PAGE", "")
    req2 = Request.new("SITE.TEST", "PAGE", nil)
    assert_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req1) }
    assert_no_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req2) }
    assert_equal(2, ActiveAnalytics::ViewsPerDay.last.total)
  end

  def test_queue_request_and_flush_queue
    req1, req2, req3, req4 = sample_requests
    ActiveAnalytics.redis.del("ActiveAnalytics::Queue")
    ActiveAnalytics.redis.del("ActiveAnalytics::OldQueue")

    ActiveAnalytics.queue_request(req1)
    ActiveAnalytics.queue_request(req2)
    ActiveAnalytics.queue_request(req3)
    ActiveAnalytics.queue_request(req4)

    assert_equal(3, ActiveAnalytics.redis.hlen("ActiveAnalytics::Queue"), ActiveAnalytics.redis.hgetall("ActiveAnalytics::Queue"))
    assert_difference("ActiveAnalytics::ViewsPerDay.count", 3) { ActiveAnalytics.flush_queue; }
    assert_equal(2, ActiveAnalytics::ViewsPerDay.where(site: "site.test", page: "fst", referrer_host: "site.test", referrer_path: "/previous_page").first.total)
    assert_equal(1, ActiveAnalytics::ViewsPerDay.where(site: "site.test", page: "snd", referrer_host: "site.test", referrer_path: "/").first.total)
    assert_equal(1, ActiveAnalytics::ViewsPerDay.where(site: "site.test", page: "thrd", referrer_host: "site.test", referrer_path: "").first.total)
    assert_equal(0, ActiveAnalytics.redis.exists("ActiveAnalytics::Queue"))
    assert_equal(0, ActiveAnalytics.redis.exists("ActiveAnalytics::OldQueue"))
    assert_no_difference("ActiveAnalytics::ViewsPerDay.sum(:total)") { ActiveAnalytics.flush_queue; }

    ActiveAnalytics.queue_request(req1)
    assert_difference("ActiveAnalytics::ViewsPerDay.sum(:total)", 1) do
      assert_no_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.flush_queue; }
    end
    assert_equal(3, ActiveAnalytics::ViewsPerDay.where(site: "site.test", page: "fst", referrer_host: "site.test", referrer_path: "/previous_page").first.total)
    assert_equal(1, ActiveAnalytics::ViewsPerDay.where(site: "site.test", page: "snd", referrer_host: "site.test", referrer_path: "/").first.total)
    assert_equal(1, ActiveAnalytics::ViewsPerDay.where(site: "site.test", page: "thrd", referrer_host: "site.test", referrer_path: "").first.total)
  end

  def test_user_agent_request_mobile_firefox_twice
    ActiveAnalytics.record_request(
      user_agent_request('Mozilla/5.0 (Android 14; Mobile; LG-M255; rv:123.0) Gecko/123.0 Firefox/123.0')
    )
    ActiveAnalytics.record_request(
      user_agent_request('Mozilla/5.0 (Android 12; Mobile; LG-M255; rv:123.0) Gecko/111.0 Firefox/110.0')
    )

    view = ActiveAnalytics::ViewsPerDay.first
    assert_equal 1, ActiveAnalytics::ViewsPerDay.count
    assert_equal 2, view.total
    assert_equal "firefox", view.browser
    assert_equal "mobile", view.device_type
    assert_equal "android", view.operating_system
  end

  def test_multiple_user_agent
    ActiveAnalytics.record_request(
      user_agent_request('Mozilla/5.0 (iPhone14,3; U; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/19A346 Safari/602.1')
    )
    ActiveAnalytics.record_request(
      user_agent_request('Mozilla/5.0 (Android 12; Mobile; LG-M255; rv:123.0) Gecko/111.0 Firefox/110.0')
    )

    assert_equal 2, ActiveAnalytics::ViewsPerDay.count
    assert_equal 1, ActiveAnalytics::ViewsPerDay.first.total
    assert_equal "safari", ActiveAnalytics::ViewsPerDay.first.browser
    assert_equal 1, ActiveAnalytics::ViewsPerDay.second.total
    assert_equal "firefox", ActiveAnalytics::ViewsPerDay.second.browser
  end

  private

  def sample_requests
    [
      Request.new("site.test", "fst", "http://site.test/previous_page"),
      Request.new("SITE.TEST", "FST", "http://SITE.TEST/PREVIOUS_PAGE"),
      Request.new("site.test", "snd", "http://site.test/"),
      Request.new("site.test", "thrd", "http://site.test"),
    ]
  end

  def user_agent_request(ua)
    Request.new("site.test", "page", "http://site.test", ua)
  end
end
