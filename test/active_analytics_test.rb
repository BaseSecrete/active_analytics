require "test_helper"
require "redis"

class ActiveAnalyticsTest < ActiveSupport::TestCase
  Request = Struct.new(:host, :path, :referrer, :headers)

  def test_record_request_with_referrer
    req1, req2, req3, req4 = sample_requests

    assert_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req1) }
    assert_no_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req2) }
    assert_equal(2, ActiveAnalytics::ViewsPerDay.last.total)
    assert_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req3) }
    assert_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req4) }
  end

  def test_record_request_without_referrer
    req1 = Request.new("SITE.TEST", "PAGE", "", {})
    req2 = Request.new("SITE.TEST", "PAGE", nil, {})
    assert_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req1) }
    assert_no_difference("ActiveAnalytics::ViewsPerDay.count") { ActiveAnalytics.record_request(req2) }
    assert_equal(2, ActiveAnalytics::ViewsPerDay.last.total)
  end

  def test_record_request_with_user_agent
    req1, req2 = sample_requests
    assert_difference("ActiveAnalytics::BrowsersPerDay.count") { ActiveAnalytics.record_request(req1) }
    assert_no_difference("ActiveAnalytics::BrowsersPerDay.count") { ActiveAnalytics.record_request(req2) }
    assert_equal(2, ActiveAnalytics::BrowsersPerDay.last.total)
  end

  def test_queue_request_and_flush_queue
    req1, req2, req3, req4 = sample_requests
    ActiveAnalytics.redis.del(ActiveAnalytics::PAGE_QUEUE)
    ActiveAnalytics.redis.del(ActiveAnalytics::OLD_PAGE_QUEUE)
    ActiveAnalytics.redis.del(ActiveAnalytics::BROWSER_QUEUE)
    ActiveAnalytics.redis.del(ActiveAnalytics::OLD_BROWSER_QUEUE)

    ActiveAnalytics.queue_request(req1)
    ActiveAnalytics.queue_request(req2)
    ActiveAnalytics.queue_request(req3)
    ActiveAnalytics.queue_request(req4)

    assert_equal(3, ActiveAnalytics.redis.hlen("ActiveAnalytics::PageQueue"), ActiveAnalytics.redis.hgetall("ActiveAnalytics::PageQueue"))
    assert_equal(1, ActiveAnalytics.redis.hlen("ActiveAnalytics::BrowserQueue"), ActiveAnalytics.redis.hgetall("ActiveAnalytics::BrowserQueue"))

    assert_difference("ActiveAnalytics::BrowsersPerDay.count", 1) do
      assert_difference("ActiveAnalytics::ViewsPerDay.count", 3) do
        ActiveAnalytics.flush_queue
      end
    end

    assert_equal(2, ActiveAnalytics::ViewsPerDay.where(site: "site.test", page: "page", referrer_host: "site.test", referrer_path: "/previous_page").first.total)
    assert_equal(4, ActiveAnalytics::BrowsersPerDay.where(site: "site.test", name: "Firefox", version: "128").first.total)

    assert_equal(0, ActiveAnalytics.redis.exists("ActiveAnalytics::PageQueue"))
    assert_equal(0, ActiveAnalytics.redis.exists("ActiveAnalytics::OldPageQueue"))

    assert_equal(0, ActiveAnalytics.redis.exists("ActiveAnalytics::BrowserQueue"))
    assert_equal(0, ActiveAnalytics.redis.exists("ActiveAnalytics::OldBrowserQueue"))

    assert_no_difference("ActiveAnalytics::ViewsPerDay.sum(:total)") do
      assert_no_difference("ActiveAnalytics::ViewsPerDay.sum(:total)") do
        ActiveAnalytics.flush_queue
      end
    end

    ActiveAnalytics.queue_request(req1)
    assert_difference("ActiveAnalytics::BrowsersPerDay.sum(:total)", 1) do
      assert_difference("ActiveAnalytics::ViewsPerDay.sum(:total)", 1) do
        assert_no_difference("ActiveAnalytics::BrowsersPerDay.count") do
          assert_no_difference("ActiveAnalytics::ViewsPerDay.count") do
            ActiveAnalytics.flush_queue
          end
        end
      end
    end
    assert_equal(3, ActiveAnalytics::ViewsPerDay.where(site: "site.test", page: "page", referrer_host: "site.test", referrer_path: "/previous_page").first.total)
  end

  private

  def sample_requests
    [
      Request.new("site.test", "page", "http://site.test/previous_page", sample_headers),
      Request.new("SITE.TEST", "page", "http://SITE.TEST/previous_page", sample_headers),
      Request.new("site.test", "page", "http://site.test/", sample_headers),
      Request.new("site.test", "page", "http://site.test", sample_headers),
    ]
  end

  def sample_headers
    {"User-Agent" => "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"}
  end
end
