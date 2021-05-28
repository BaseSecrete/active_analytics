require "test_helper"

class ActiveAnalyticsTest < ActiveSupport::TestCase
  Request = Struct.new(:host, :path, :referrer)

  def test_record_request_with_referrer
    req1 = Request.new("site.test", "page", "http://site.test/previous_page")
    req2 = Request.new("SITE.TEST", "PAGE", "http://SITE.TEST/PREVIOUS_PAGE")
    req3 = Request.new("site.test", "page", "http://site.test/")
    req4 = Request.new("site.test", "page", "http://site.test")

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
end
