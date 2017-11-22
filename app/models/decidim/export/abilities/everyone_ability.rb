# frozen_string_literal: true

module Decidim
  module Export
    module Abilities
      # Defines the base abilities related to Export for any user. Guest users
      # will use these too. Intended to be used with `cancancan`.
      class EveryoneAbility < Decidim::Abilities::EveryoneAbility
        def initialize(user, context)
          super(user, context)

          can :read, Export, &:published?
        end
      end
    end
  end
end
