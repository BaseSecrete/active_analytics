require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class ReferrersController < ApplicationController
    def index
      @referrers = ViewsPerDay.where(site: params[:site]).top(100).group_by_referer_site
    end

    def show
      @pages = ViewsPerDay.where(site: params[:site], referer_host: params[:referrer]).top(100).group_by_referer_page
    end
  end
end
