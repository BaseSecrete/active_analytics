require "test_helper"

module ActiveAnalytics
  class BrowsersPerDayTest < ActiveSupport::TestCase
    def test_append
      assert_difference("BrowsersPerDay.count") do
        BrowsersPerDay.append(site: "site.example", date: Date.today, name: "Firefox", version: 123)
      end

      assert_equal("Firefox", (browser = BrowsersPerDay.last).name)
      assert_equal("123", browser.version)

      assert_no_difference("BrowsersPerDay.count") do
        browser = BrowsersPerDay.append(site: "SITE.EXAMPLE", date: Date.today, name: "Firefox", version: 123)
        assert_equal(2, browser.total)
      end

      assert_difference("BrowsersPerDay.count") do
        BrowsersPerDay.append(site: "site.example", date: Date.today, name: "Firefox", version: 456)
      end

      assert_equal("Firefox", (browser = BrowsersPerDay.last).name)
      assert_equal("456", browser.version)
    end
  end
end
