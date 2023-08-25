require "test_helper"
require "redis"

class ActiveAnalyticsTest < ActiveSupport::TestCase
  Request = Struct.new(:host, :path, :referrer)

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
    assert_equal(2, ActiveAnalytics::ViewsPerDay.where(site: "site.test", page: "page", referrer_host: "site.test", referrer_path: "/previous_page").first.total)
    assert_equal(0, ActiveAnalytics.redis.exists("ActiveAnalytics::Queue"))
    assert_equal(0, ActiveAnalytics.redis.exists("ActiveAnalytics::OldQueue"))
    assert_no_difference("ActiveAnalytics::ViewsPerDay.sum(:total)") { ActiveAnalytics.flush_queue; }

    ActiveAnalytics.queue_request(req1)
    assert_difference("ActiveAnalytics::ViewsPerDay.sum(:total)", 1) do
      assert_no_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.flush_queue; }
    end
    assert_equal(3, ActiveAnalytics::ViewsPerDay.where(site: "site.test", page: "page", referrer_host: "site.test", referrer_path: "/previous_page").first.total)
  end

  private

  def sample_requests
    [
      Request.new("site.test", "page", "http://site.test/previous_page"),
      Request.new("SITE.TEST", "PAGE", "http://SITE.TEST/PREVIOUS_PAGE"),
      Request.new("site.test", "page", "http://site.test/"),
      Request.new("site.test", "page", "http://site.test"),
    ]
  end
end
