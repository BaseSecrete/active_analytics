module ActiveAnalytics
  class BrowsersPerDay < ApplicationRecord
    # TODO: Deduplicate
    scope :top, -> (n = 10) { order_by_totals.limit(n) }
    scope :order_by_date, -> { order(:date) }
    scope :order_by_totals, -> { order(Arel.sql("SUM(total) DESC")) }
    scope :between_dates, -> (from, to) { where(date: from..to) }

    def self.append(params)
      total = params.delete(:total) || 1
      params[:site] = params[:site].downcase if params[:site]
      where(params).first.try(:increment!, :total, total) || create!(params.merge(total: total))
    end

    def self.group_by_name
      group(:name).select("name, sum(total) AS total")
    end

    def self.group_by_version
      group(:name, :version).select("version, sum(total) AS total")
    end

    def self.group_by_date
      group(:date).select("date, sum(total) as total")
    end

    def self.filter_by(params)
      scope = all
      scope = scope.between_dates(params[:from], params[:to]) if params[:from].present? && params[:to].present?
      scope = scope.where(site: params[:site]) if params[:site].present?
      scope = scope.where(name: params[:id]) if params[:id].present?
      scope = scope.where(version: params[:version]) if params[:version].present?
      scope
    end

    def to_param
      name
    end
  end
end
