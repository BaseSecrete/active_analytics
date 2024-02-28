require "test_helper"

module ActiveAnalytics
  class ViewsPerDayTest < ActiveSupport::TestCase
    def test_user_agent_columns_migrated
      assert_equal([:browser, :device_type, :operating_system], ViewsPerDay.user_agent_columns)
    end

    def test_group_by_site_multiple_browser
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: Date.today, browser: :firefox, total: 1)
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: 2.days.ago, browser: :chrome, total: 10)
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: 3.days.ago, browser: :safari, total: 100)
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: 4.days.ago, browser: :firefox, total: 1000)

      sites = ViewsPerDay.group_by_site
      assert_equal(1, sites.size)
      rorvswild_com = sites.first
      assert_equal(1111, rorvswild_com.total)
      assert_equal({ firefox: 1001, chrome: 10, safari: 100 }, rorvswild_com.browsers)
    end

    def test_group_by_site_multiple_device_type
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: Date.today, device_type: :phone, total: 1)
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: 2.days.ago, device_type: :tablet, total: 10)
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: 3.days.ago, device_type: :desktop, total: 100)
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: 4.days.ago, device_type: :phone, total: 1000)

      sites = ViewsPerDay.group_by_site
      assert_equal(1, sites.size)
      rorvswild_com = sites.first
      assert_equal(1111, rorvswild_com.total)
      assert_equal({ phone: 1001, tablet: 10, desktop: 100 }, rorvswild_com.device_types)
    end

    def test_group_by_site_multiple_operating_system
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: Date.today, operating_system: :linux, total: 1)
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: 2.days.ago, operating_system: :windows, total: 10)
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: 3.days.ago, operating_system: :android, total: 100)
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: 4.days.ago, operating_system: :linux, total: 1000)

      sites = ViewsPerDay.group_by_site
      assert_equal(1, sites.size)
      rorvswild_com = sites.first
      assert_equal(1111, rorvswild_com.total)
      assert_equal({ linux: 1001, windows: 10, android: 100 }, rorvswild_com.operating_systems)
    end

    def test_histogram
      ViewsPerDay.create!(site: "rorvswild.com", page: "/", date: Date.today, total: 1)

      scope = ViewsPerDay.where(site: "rorvswild.com").order_by_date.group_by_date
      histogram = ViewsPerDay::Histogram.new(scope, Date.yesterday, Date.tomorrow)

      assert_equal(3, histogram.bars.size)

      assert_equal(Date.yesterday, histogram.bars[0].label)
      assert_equal(0, histogram.bars[0].value)

      assert_equal(Date.today, histogram.bars[1].label)
      assert_equal(1, histogram.bars[1].value)

      assert_equal(Date.tomorrow, histogram.bars[2].label)
      assert_equal(0, histogram.bars[2].value)
    end

    def test_split_referrer
      assert_equal([nil, nil], ViewsPerDay.split_referrer(nil))
      assert_equal([nil, nil], ViewsPerDay.split_referrer(""))
      assert_equal(["domain.test", nil], ViewsPerDay.split_referrer("domain.test"))
      assert_equal(["domain.test", "/1"], ViewsPerDay.split_referrer("domain.test/1"))
      assert_equal(["domain.test", "/1/2"], ViewsPerDay.split_referrer("domain.test/1/2"))
      assert_equal(["domain.test", nil], ViewsPerDay.split_referrer("https://domain.test"))
      assert_equal(["domain.test", "/"], ViewsPerDay.split_referrer("https://domain.test/"))
      assert_equal(["domain.test", "/1"], ViewsPerDay.split_referrer("https://domain.test/1"))
      assert_equal(["domain.test", "/1/2"], ViewsPerDay.split_referrer("https://domain.test/1/2"))
    end
  end
end
