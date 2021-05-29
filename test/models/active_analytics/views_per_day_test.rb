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
  end
end
