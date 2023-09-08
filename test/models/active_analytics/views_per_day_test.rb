require "test_helper"

module ActiveAnalytics
  class ViewsPerDayTest < ActiveSupport::TestCase
    def test_histogram
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
