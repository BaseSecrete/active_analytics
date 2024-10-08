module ActiveAnalytics
  class ViewsPerDay < ApplicationRecord
    validates_presence_of :site, :page, :date

    scope :between_dates, -> (from, to) { where("date BETWEEN ? AND ?", from, to) }
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
      group(:date).select("date, sum(total) AS total")
    end

    def self.to_histogram
      Histogram.new(self)
    end

    def self.append(params)
      total = params.delete(:total) || 1
      params[:site] = params[:site].downcase if params[:site]
      params[:referrer_path] = nil if params[:referrer_path].blank?
      params[:referrer_path] = params[:referrer_path].downcase if params[:referrer_path]
      params[:referrer_host] = params[:referrer_host].downcase if params[:referrer_host]
      where(params).first.try(:increment!, :total, total) || create!(params.merge(total: total))
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
