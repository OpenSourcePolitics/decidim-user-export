# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:export) do |component|
  component.engine = Decidim::Export::Engine
  component.engine = Decidim::Export::AdminEngine
  component.icon = "decidim/export/icon.svg"
end
