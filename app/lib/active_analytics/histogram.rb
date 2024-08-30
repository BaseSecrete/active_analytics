module ActiveAnalytics
  class Histogram
    attr_reader :bars, :from_date, :to_date

    def initialize(scope, from_date, to_date)
      @scope = scope
      @from_date, @to_date = from_date, to_date
      @bars = scope.map { |day| Bar.new(day.day, day.total, self) }
      fill_missing_days(@bars, @from_date, @to_date)
    end

    def fill_missing_days(bars, from, to)
      i = 0
      while (day = from + i) <= to
        if !@bars[i] || @bars[i].label != day
          @bars.insert(i, Bar.new(day, 0, self))
        end
        i += 1
      end
      @bars
    end

    def max_value
      @max_total ||= bars.map(&:value).max
    end

    def total
      @bars.reduce(0) { |sum, bar| sum += bar.value }
    end

    class Bar
      attr_reader :label, :value, :histogram

      def initialize(label, value, histogram)
        @label, @value, @histogram = label, value, histogram
      end

      def height
        if histogram.max_value > 0
          (value.to_f / histogram.max_value).round(2)
        else
          0
        end
      end
    end
  end
end
