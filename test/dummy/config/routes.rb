Rails.application.routes.draw do
  mount ActiveAnalytics::Engine => "/analytics"
end
