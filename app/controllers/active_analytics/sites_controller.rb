require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class SitesController < ApplicationController
    def index
      @sites = ViewsPerDay.after(30.days.ago).order_by_totals.group_by_site
    end

    def show
      scope = ViewsPerDay.where(site: params[:site]).after(30.days.ago).order_by_totals.limit(25)
      @views_per_day = scope.group_by_date
      @referers = scope.group_by_referer
      @pages = scope.group_by_page
    end
  end
end
