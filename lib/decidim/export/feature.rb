# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:export) do |feature|
  feature.engine = Decidim::Export::Engine
  feature.engine = Decidim::Export::AdminEngine
  feature.icon = "decidim/export/icon.svg"
end
