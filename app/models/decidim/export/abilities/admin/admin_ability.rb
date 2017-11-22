# frozen_string_literal: true

module Decidim
  module Export
    module Abilities
      module Admin
        # Defines the abilities for an admin user. Intended to be used with `cancancan`.
        class AdminAbility < Decidim::Abilities::AdminAbility
          def define_abilities
            super

            can :manage, Export
          end
        end
      end
    end
  end
end
