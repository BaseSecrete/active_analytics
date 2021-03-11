require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class SitesController < ApplicationController
    def index
      @sites = ViewsPerDay.after(30.days.ago).order_by_totals.group_by_site
    end
  end
end
