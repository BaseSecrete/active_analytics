module ActiveAnalytics
  class ViewsPerDay < ApplicationRecord
    validates_presence_of :site, :page, :date

    scope :after, -> (date) { where("date > ?", date) }
    scope :order_by_totals, -> { order(Arel.sql("SUM(total) DESC")) }
    scope :order_by_date, -> { order(:date) }
    scope :top, -> (n = 10) { order_by_totals.limit(n) }

    class Site
      attr_reader :host, :total
      def initialize(host, total)
        @host, @total = host, total
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

    def self.group_by_site
      group(:site).pluck("site, SUM(total)").map do |row|
        Site.new(row[0], row[1])
      end
    end

    def self.group_by_page
      group(:site, :page).pluck("site, page, SUM(total)").map do |row|
        Page.new(row[0], row[1], row[2])
      end
    end

    def self.group_by_referer_site
      group(:referer_host).pluck("referer_host, SUM(total)").map do |row|
        Site.new(row[0], row[1])
      end
    end

    def self.group_by_referer_page
      group(:referer_host, :referer_path).pluck("referer_host, referer_path, SUM(total)").map do |row|
        Page.new(row[0], row[1], row[2])
      end
    end

    def self.group_by_date
      group(:date).pluck("date, SUM(total)").map do |row|
        Day.new(row[0], row[1])
      end
    end

    def self.append(params)
      vpd = find_or_initialize_by(params)
      vpd.referer_path = nil if vpd.referer_path?
      vpd.total += 1 if vpd.persisted?
      vpd.save!
    end
  end
end
