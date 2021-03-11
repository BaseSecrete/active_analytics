ActiveAnalytics::Engine.routes.draw do
  get "/:site", to: "sites#show", as: :site, constraints: {site: /[^\/]+/}
  get "/:site/*page", to: "pages#show", as: :page, constraints: {site: /[^\/]+/}
  root to: "sites#index", as: :active_analytics
end
