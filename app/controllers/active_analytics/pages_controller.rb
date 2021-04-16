require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class PagesController < ApplicationController
    include PagesHelper

    before_action :require_date_range

    def index
      scope = ViewsPerDay.where(site: params[:site]).between_dates(params[:from], params[:to])
      @histogram = ViewsPerDay::Histogram.new(scope.order_by_date.group_by_date)
      @pages = scope.top(100).group_by_page
    end

    def show
      scope = ViewsPerDay.where(site: params[:site], page: page_from_params).between_dates(params[:from], params[:to])
      @histogram = ViewsPerDay::Histogram.new(scope.order_by_date.group_by_date)
      @referrers = scope.top.group_by_referrer_site

      @next_pages = ViewsPerDay.where(referrer_host: params[:site], referrer_path: page_from_params).top.group_by_page
      @previous_pages = ViewsPerDay.where(site: params[:site], page: page_from_params).top.group_by_referrer_page
    end
  end
end
