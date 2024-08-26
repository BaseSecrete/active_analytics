require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class BrowsersController < ApplicationController
    def index
      @histogram = Histogram.new(current_browsers_per_days.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = Histogram.new(previous_browsers_per_days.order_by_date.group_by_date, previous_from_date, previous_to_date)
      @browsers = current_browsers_per_days.group_by_name.top(100)
    end

    def show
      @histogram = Histogram.new(current_browsers_per_days.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = Histogram.new(previous_browsers_per_days.order_by_date.group_by_date, previous_from_date, previous_to_date)
      @browsers = current_browsers_per_days.group_by_version.top(100)
    end

    private

    def current_browsers_per_days
      BrowsersPerDay.filter_by(params)
    end

    def previous_browsers_per_days
      BrowsersPerDay.filter_by(params.merge(from: previous_from_date, to: previous_to_date))
    end
  end
end
