require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class SitesController < ApplicationController
    def index
      @sites = ViewsPerDay.after(30.days.ago).order_by_totals.group_by_site
    end

    def show
      scope = ViewsPerDay.where(site: params[:site]).after(30.days.ago)
      @views_per_day = scope.order_by_date.group_by_date
      @histogram = ViewsPerDay::Histogram.new(@views_per_day)
      @referrers = scope.top.group_by_referrer_site
      @pages = scope.top.group_by_page
    end
  end
end
