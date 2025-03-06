# frozen_string_literal: true

require_dependency "active_analytics/application_controller"

module ActiveAnalytics
  class AssetsController < ApplicationController
    protect_from_forgery except: :show

    @@root = ActiveAnalytics::Engine.root.join("app/views", controller_path + "/").to_s

    def self.endpoints
      return @endpoints if @endpoints
      paths = Dir["#{@@root}**/*"].keep_if { |path| File.file?(path) }
      files = paths.map { |path| path.to_s.delete_prefix(@@root).delete_suffix(".erb") }
      @endpoints = files.delete_if { |str| str.start_with?("_") }
    end

    def show
      if self.class.endpoints.include?(params[:file])
        expires_in(1.day, public: true)
        render_asset(params[:file])
      else
        raise ActionController::RoutingError.new("Not found #{params[:file]}")
      end
    end

    private

    def render_asset(path)
      ext = File.extname(params[:file])
      path_without_ext = path.delete_suffix(ext)
      mime_type = Mime::Type.lookup_by_extension(ext.delete_prefix("."))
      render("#{controller_path}/#{path_without_ext}", mime_type: mime_type)
    end
  end
end
