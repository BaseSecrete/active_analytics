module ActiveAnalytics
  class ViewsPerDay < ApplicationRecord
    validates_presence_of :site, :page, :date

    scope :after, -> (date) { where("date > ?", date) }
    scope :order_by_totals, -> { order(Arel.sql("SUM(total) DESC")) }

    class Page
      attr_reader :host, :path, :total
      def initialize(host, path, total)
        @host, @path, @total = host, path, total
      end
    end

    class Day
      attr_reader :day, :total
      def initialize(day, total)
        @day, @total = day, total
      end
    end

    def self.group_by_site
      group(:site).pluck("site, SUM(total)").map do |row|
        Page.new(row[0], nil, row[1])
      end
    end

    def self.group_by_page
      group(:site, :page).pluck("site, page, SUM(total)").map do |row|
        Page.new(row[0], row[1], row[2])
      end
    end

    def self.group_by_referer
      group(:referer_host).pluck("referer_host, SUM(total)").map do |row|
        Page.new(row[0], nil, row[1])
      end
    end

    def self.group_by_date
      group(:date).pluck("date, SUM(total)").map do |row|
        Day.new(row[0], row[1])
      end
    end

    def self.append(params)
      vpd = find_or_initialize_by(params)
      vpd.total += 1 if vpd.persisted?
      vpd.save!
    end
  end
end
