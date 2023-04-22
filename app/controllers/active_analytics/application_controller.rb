module ActiveAnalytics
  class ApplicationController < ActionController::Base

    private

    def require_date_range
      if Date.parse(params[:from]) > Date.parse(params[:to])
        redirect_to(params.to_unsafe_hash.merge(from: params[:to], to: params[:from]))
      end
    rescue TypeError, ArgumentError # Raise by Date.parse when invalid format
      redirect_to(params.to_unsafe_hash.merge(from: 7.days.ago.to_date, to: Date.today))
    end

    def current_views_per_days
      ViewsPerDay.where(site: params[:site]).between_dates(params[:from], params[:to])
    end
  end
end
