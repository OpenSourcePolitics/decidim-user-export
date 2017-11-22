# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "decidim-export"
  s.summary     = "User export engine"
  s.description = s.summary
  s.version     = "0.0.1"
  s.authors     = ["Open Source Projects"]

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  s.add_dependency "decidim-core"

  s.add_development_dependency "decidim-dev"
  s.add_development_dependency "decidim-admin"
end
