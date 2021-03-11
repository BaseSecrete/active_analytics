require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class ReferrersController < ApplicationController
    def index
      @referrers = ViewsPerDay.where(site: params[:site]).top(100).group_by_referrer_site
    end

    def show
      @pages = ViewsPerDay.where(site: params[:site], referrer_host: params[:referrer]).top(100).group_by_referrer_page
    end
  end
end
