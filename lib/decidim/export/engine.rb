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
    end
  end
end
