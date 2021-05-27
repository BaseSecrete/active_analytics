module ActiveAnalytics
  class ApplicationController < ActionController::Base

    private

    def require_date_range
      if params[:from].blank? || params[:to].blank?
        redirect_to(params.to_unsafe_hash.merge(from: 7.days.ago.to_date, to: Date.today))
      end
    end

    def current_views_per_days
      ViewsPerDay.where(site: params[:site]).between_dates(params[:from], params[:to])
    end
  end
end
