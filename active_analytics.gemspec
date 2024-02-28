require_relative "lib/active_analytics/version"

Gem::Specification.new do |spec|
  spec.name        = "active_analytics"
  spec.version     = ActiveAnalytics::VERSION
  spec.authors     = ["Alexis Bernard", "Antoine Marguerie"]
  spec.email       = ["alexis@basesecrete.com", "antoine@basesecrete.com"]
  spec.homepage    = "https://github.com/BaseSecrete/active_analytics"
  spec.summary     = "First-party, privacy-focused traffic analytics for Ruby on Rails applications"
  spec.description = "NO cookies, NO JavaScript, NO third parties and NO bullshit."
  spec.license     = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/BaseSecrete/active_analytics"
  spec.metadata["changelog_uri"] = "https://github.com/BaseSecrete/active_analytics"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "browser", ">= 5.3.1"
end
