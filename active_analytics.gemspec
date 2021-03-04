require_relative "lib/active_analytics/version"

Gem::Specification.new do |spec|
  spec.name        = "active_analytics"
  spec.version     = ActiveAnalytics::VERSION
  spec.authors     = ["Alexis Bernard"]
  spec.email       = ["alexis@basesecrete.com"]
  spec.homepage    = "https://github.com/BaseSecrete/active_analytics"
  spec.summary     = "Trafic analytics for the win of privacy"
  spec.description = "NO cookies, NO JavaScript, NO third parties and NO bullshit"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/BaseSecrete/active_analytics"
  spec.metadata["changelog_uri"] = "https://github.com/BaseSecrete/active_analytics"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.0"
end
