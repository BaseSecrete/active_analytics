module ActiveAnalytics
  class ViewsPerDay < ApplicationRecord
    validates_presence_of :site, :page, :date

    scope :between_dates, -> (from, to) { where("date BETWEEN ? AND ?", from, to) }
    scope :after, -> (date) { where("date > ?", date) }
    scope :order_by_totals, -> { order(Arel.sql("SUM(total) DESC")) }
    scope :order_by_date, -> { order(:date) }
    scope :top, -> (n = 10) { order_by_totals.limit(n) }

    def self.user_agent_columns
      @@user_agent_columns ||= [:browser, :device_type, :operating_system]
                                 .select {|n| ViewsPerDay.column_names.include?(n.to_s)}
    end

    def self.unique_by_columns
      @@unique_by_columns ||= [:date, :site, :page, :referrer_path, :referrer_host].concat(self.user_agent_columns)
    end

    class Site
      attr_reader :host, :total, :browsers, :device_types, :operating_systems
      def initialize(host, total, browsers, device_types, operating_systems)
        @host, @total, @browsers, @device_types, @operating_systems = host, total, browsers, device_types, operating_systems
      end
    end

    class Page
      attr_reader :host, :path, :total
      def initialize(host, path, total)
        @host, @path, @total = host, path, total
      end

      def url
        host + path
      end
    end

    class Day
      attr_reader :day, :total
      def initialize(day, total)
        @day, @total = day, total
      end
    end

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

    def self.group_by_site
      group(:site, :browser, :device_type, :operating_system)
        .pluck("site, browser, device_type, operating_system, SUM(total)")
        .to_a
        .group_by { |r| r[0] }
        .map do |site_name, grouped_site|
          total_sum = 0
          browsers = Hash.new(0)
          device_types = Hash.new(0)
          operating_systems = Hash.new(0)

          grouped_site.each do |row|
            total_group = row[4].to_i
            browsers[row[1].to_sym] += total_group if row[1]
            device_types[row[2].to_sym] += total_group if row[2]
            operating_systems[row[3].to_sym] += total_group if row[3]
            total_sum += total_group
          end
          Site.new(site_name, total_sum, browsers, device_types, operating_systems)
        end
    end

    def self.group_by_page
      group(:site, :page).pluck("site, page, SUM(total)").map do |row|
        Page.new(row[0], row[1], row[2])
      end
    end

    def self.group_by_referrer_site
      group(:referrer_host).pluck("referrer_host, SUM(total)").map do |row|
        Site.new(row[0], row[1])
      end
    end

    def self.group_by_referrer_page
      group(:referrer_host, :referrer_path).pluck("referrer_host, referrer_path, SUM(total)").map do |row|
        Page.new(row[0], row[1], row[2])
      end
    end

    def self.group_by_date
      group(:date).pluck("date, SUM(total)").map do |row|
        Day.new(row[0], row[1])
      end
    end

    def self.to_histogram
      ViewsPerDay::Histogram.new(self)
    end

    def self.append(params)
      increment = params[:total] || 1
      params[:referrer_path] = "" if params[:referrer_path].blank?
      [:site, :page, :referrer_path, :referrer_host].each do |attr|
        params[attr] = if params[attr]
                         params[attr].downcase
                       else
                         ""
                       end
      end

      record = ViewsPerDay.upsert(
        params,
        unique_by: ViewsPerDay.unique_by_columns,
        on_duplicate: Arel.sql("total = total + #{increment.to_i}"),
        record_timestamps: false
      )

      # where(params).first.try(:increment!, :total, increment.to_i) || create!(params.merge(total: increment))
    end

    SLASH = "/"

    def self.split_referrer(referrer)
      return [nil, nil] if referrer.blank?
      if (uri = URI(referrer)).host.present?
        [uri.host, uri.path.presence]
      else
        strings = referrer.split(SLASH, 2)
        [strings[0], strings[1] ? SLASH + strings[1] : nil]
      end
    end
  end
end
