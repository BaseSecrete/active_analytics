ActiveAnalytics::Engine.routes.draw do
  get "/:site", to: "page_views#show", as: :page_view
  get "/:site/*page", to: "page_views#show"
  root to: "page_views#index"
end
