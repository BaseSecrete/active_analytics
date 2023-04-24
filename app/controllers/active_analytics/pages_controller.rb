require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class PagesController < ApplicationController
    include PagesHelper

    before_action :require_date_range

    def index
      @histogram = ViewsPerDay::Histogram.new(current_views_per_days.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = ViewsPerDay::Histogram.new(previous_views_per_days.order_by_date.group_by_date, previous_from_date, previous_to_date)
      @pages = current_views_per_days.top(100).group_by_page
    end

    def show
      page_scope = current_views_per_days.where(page: page_from_params)
      @histogram = ViewsPerDay::Histogram.new(page_scope.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = ViewsPerDay::Histogram.new(previous_views_per_days.order_by_date.group_by_date, previous_from_date, previous_to_date)
      @next_pages = current_views_per_days.where(referrer_host: params[:site], referrer_path: page_from_params).top(100).group_by_page
      @previous_pages = page_scope.top(100).group_by_referrer_page
    end
  end
end
