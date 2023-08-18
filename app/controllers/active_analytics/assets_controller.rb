require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class AssetsController < ApplicationController
    protect_from_forgery except: :show

    def show
      if endpoints.include?(File.basename(request.path))
        expires_in(1.day, public: true)
        render(params[:id], mime_type: mime_type)
      else
        raise ActionController::RoutingError.new
      end
    end

    private

    def endpoints
      return @endpoints if @endpoints
      folder = ActiveAnalytics::Engine.root.join("app/views", controller_path)
      files = folder.each_child.map { |path| File.basename(path).delete_suffix(".erb") }
      @endpoints = files.delete_if { |str| str.start_with?("_") }
    end

    def mime_type
      Mime::Type.lookup_by_extension(File.extname(request.path).delete_prefix("."))
    end
  end
end
