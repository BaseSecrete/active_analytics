ActiveAnalytics::Engine.routes.draw do
  get "/assets/*file", to: "assets#show", constraints: {file: /.+/}, as: :asset

  get "/:site", to: "sites#show", as: :site, constraints: {site: /[^\/]+/}

  # Referrers
  get "/:site/referrers", to: "referrers#index", constraints: {site: /[^\/]+/}, as: :referrers
  get "/:site/referrers/*referrer", to: "referrers#show", as: :referrer, constraints: {site: /[^\/]+/, referrer: /.+/}

  # Browsers
  get "/:site/browsers", to: "browsers#index", constraints: {site: /[^\/]+/}, as: :browsers
  get "/:site/browsers/:id", to: "browsers#show", constraints: {site: /[^\/]+/}, as: :browser

  # Pages
  get "/:site/pages", to: "pages#index", constraints: {site: /[^\/]+/}, as: :pages
  get "/:site/*page", to: "pages#show", as: :page, constraints: {site: /[^\/]+/}

  root to: "sites#index", as: :active_analytics
end
