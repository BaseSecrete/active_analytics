module ActiveAnalytics
  class ApplicationController < ActiveAnalytics.base_controller_class.constantize
    layout "active_analytics/application"

    helper PagesHelper
    helper SitesHelper

    private

    def from_date
      @from_date ||= Date.parse(params[:from])
    end

    def to_date
      @to_date ||= Date.parse(params[:to])
    end

    def require_date_range
      redirect_to(params.to_unsafe_hash.merge(from: to_date, to: from_date)) if from_date > to_date
    rescue TypeError, ArgumentError # Raised by Date.parse when invalid format
      redirect_to(params.to_unsafe_hash.merge(from: 7.days.ago.to_date, to: Date.today))
    end

    def current_views_per_days
      ViewsPerDay.where(site: params[:site]).between_dates(from_date, to_date)
    end

    def previous_views_per_days
      ViewsPerDay.where(site: params[:site]).between_dates(previous_from_date, previous_to_date)
    end

    def previous_from_date
      from_date - (to_date - from_date)
    end

    def previous_to_date
      to_date - (to_date - from_date)
    end
  end
end
