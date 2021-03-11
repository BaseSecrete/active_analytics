ActiveAnalytics::Engine.routes.draw do
  get "/:site", to: "sites#show", as: :site, constraints: {site: /[^\/]+/}

  get "/:site/referrers", to: "referrers#index", constraints: {site: /[^\/]+/}, as: :referrers
  get "/:site/referrers/:referrer", to: "referrers#show", constraints: {site: /[^\/]+/, referrer: /[^\/]+/}, as: :referrer

  get "/:site/*page", to: "pages#show", as: :page, constraints: {site: /[^\/]+/}
  root to: "sites#index", as: :active_analytics
end
