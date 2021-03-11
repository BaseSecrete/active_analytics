require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class PagesController < ApplicationController
    def show
      scope = ViewsPerDay.where(site: params[:site], page: "/" + params[:page]).after(30.days.ago).order_by_totals.limit(25)
      @views_per_day = scope.group_by_date
      @referers = scope.group_by_referer
      @pages = scope.group_by_page
    end
  end
end
