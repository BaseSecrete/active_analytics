require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class SitesController < ApplicationController
    before_action :require_date_range, only: :show

    def index
      @sites = ViewsPerDay.after(30.days.ago).order_by_totals.group_by_site
    end

    def show
      scope = current_views_per_days
      @histogram = ViewsPerDay::Histogram.new(scope.order_by_date.group_by_date)
      @referrers = scope.top.group_by_referrer_site
      @pages = scope.top.group_by_page
    end
  end
end
