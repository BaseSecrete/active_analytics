require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class ReferrersController < ApplicationController
    def index
      scope = ViewsPerDay.where(site: params[:site])
      @referrers = scope.top(100).group_by_referrer_site
      @histogram = ViewsPerDay::Histogram.new(scope.order_by_date.group_by_date)
    end

    def show
      scope = ViewsPerDay.where(site: params[:site], referrer_host: params[:referrer])
      @histogram = ViewsPerDay::Histogram.new(scope.order_by_date.group_by_date)
      @previous_pages = scope.top(100).group_by_referrer_page
      @next_pages = scope.top(100).group_by_page
    end
  end
end
