require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class ReferrersController < ApplicationController
    before_action :require_date_range

    def index
      scope = ViewsPerDay.where(site: params[:site]).between_dates(params[:from], params[:to])
      @referrers = scope.top(100).group_by_referrer_site
      @histogram = ViewsPerDay::Histogram.new(scope.order_by_date.group_by_date, params[:from], params[:to])
    end

    def show
      scope = ViewsPerDay.where(site: params[:site], referrer_host: params[:referrer]).between_dates(params[:from], params[:to])
      @histogram = ViewsPerDay::Histogram.new(scope.order_by_date.group_by_date, params[:from], params[:to])
      @previous_pages = scope.top(100).group_by_referrer_page
      @next_pages = scope.top(100).group_by_page
    end
  end
end
