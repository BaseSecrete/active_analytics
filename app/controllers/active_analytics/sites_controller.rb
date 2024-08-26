require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class SitesController < ApplicationController
    before_action :require_date_range, only: :show

    def index
      @sites = ViewsPerDay.after(30.days.ago).order_by_totals.group_by_site
      redirect_to(site_path(@sites.first.host)) if @sites.size == 1
    end

    def show
      @histogram = Histogram.new(current_views_per_days.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = Histogram.new(previous_views_per_days.order_by_date.group_by_date, previous_from_date, previous_to_date)
      @referrers = current_views_per_days.top.group_by_referrer_site
      @pages = current_views_per_days.top.group_by_page
      @browsers = BrowsersPerDay.filter_by(params).group_by_name.top
    end
  end
end
