require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class PageViewsController < ApplicationController
    def show
      scope = ViewsPerDay.where(site: params[:site]).after(30.days.ago).order_by_totals.limit(25)
      scope = scope.where(page: "/" + params[:page]) if params[:page]
      @pages = scope.group_by_page
      @referers = scope.group_by_referer
      @views_per_day = scope.group_by_date
    end
  end
end
