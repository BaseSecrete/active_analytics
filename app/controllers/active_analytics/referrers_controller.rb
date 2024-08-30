require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class ReferrersController < ApplicationController
    before_action :require_date_range

    def index
      @referrers = current_views_per_days.top(100).group_by_referrer_site
      @histogram = Histogram.new(current_views_per_days.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = Histogram.new(previous_views_per_days.order_by_date.group_by_date, previous_from_date, previous_to_date)
    end

    def show
      referrer_host, referrer_path = params[:referrer].split("/", 2)
      scope = current_views_per_days.where(referrer_host: referrer_host)
      scope = scope.where(referrer_path: "/" + referrer_path) if referrer_path.present?
      previous_scope = previous_views_per_days.where(referrer_host: params[:referrer])
      @histogram = Histogram.new(scope.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = Histogram.new(previous_scope.order_by_date.group_by_date, previous_from_date, previous_to_date)
      @previous_pages = scope.top(100).group_by_referrer_page
      @next_pages = scope.top(100).group_by_page
    end
  end
end
