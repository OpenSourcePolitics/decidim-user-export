# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module Export
    # Decidim's Export Rails Admin Engine.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Export::Admin

      paths["db/migrate"] = nil

      initializer "decidim_admin_export.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          mount Decidim::Export::AdminEngine => "/admin/export"
        end
      end

      routes do
        get '/show', to: 'export#show', as: 'export' # route available in decidim_export_admin.show_path
        root to: "export#index" # route available in decidim_export_admin.root_path
      end

      initializer "decidim_export.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_export_manifest.js)
      end

      initializer "decidim_export.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            "Decidim::Export::Abilities::Admin::AdminAbility"
          ]
        end
      end

      initializer "decidim_export.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.export", scope: "decidim.admin"),
            decidim_export_admin.root_path,
            icon_name: "data-transfer-download",
            position: 7.5,
            active: :inclusive,
            if: can?(:read, current_organization)
        end
      end
    end
  end
end
