module ActiveAnalytics
  module PagesHelper
    def page_to_params(name)
      name == "/" ? "index" : name[1..-1]
    end

    def page_from_params
      if params[:page] == "index"
        "/"
      elsif params[:page].present?
        "/#{params[:page]}"
      end
    end
  end
end
