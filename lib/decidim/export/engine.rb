# frozen_string_literal: true
module Decidim
  module Export
    # This is the engine that runs on the public interface of `decidim-export`.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Export

      routes do
        resources :export, only: [:show]
        root to: "export#show"
      end

      initializer "decidim_export.assets" do |app|
        app.config.assets.precompile += %w(decidim_export_manifest.js)
      end

      config.generators do |g|
        g.test_framework :rspec, :fixture => false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.assets false
        g.helper false
      end
    end
  end
end
