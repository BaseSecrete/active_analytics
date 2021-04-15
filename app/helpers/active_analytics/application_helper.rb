module ActiveAnalytics
  module ApplicationHelper
    def format_view_count(number)
      number_with_delimiter(number.to_i)
    end
  end
end
