# frozen_string_literal: true
module Decidim
  module Export
    module Admin
      # Controller that allows managing Export.
      #
      class ExportController < Decidim::Admin::ApplicationController

        layout "decidim/admin/export"

        # without the app/models/decidim/export/abilities
        # you can skip authorization with this :
        # skip_authorization_check :only => [:show]

        def index
          authorize! :index, Decidim::Export
          @participatory_spaces = participatory_spaces
        end

        def show
          authorize! :show, Decidim::Export
          users = users_to_export
          respond_to do |format|
            format.html
            format.csv do
              send_data export_data(users),
              filename: "users-#{Date.today}.csv"
            end
          end
        end

        private

        def participatory_spaces
          @participatory_process ||= Decidim::ParticipatoryProcess.where(organization: current_organization)
          @assemblies ||= if Object.const_defined?('Decidim::Assembly') # Check if the gem Decidim::Assembly is active
                             Decidim::Assembly.where(organization: current_organization)
                          else
                            []
                          end
          @participatory_process + @assemblies
        end

        def participatory_space
          if request.query_parameters[:space_id] && request.query_parameters[:space_type]
            space_id = request.query_parameters[:space_id]
            space_type = request.query_parameters[:space_type].constantize
            participatory_space = space_type.find(space_id)

            participatory_space
          end
        end

        def export_data(data)
          Decidim::Export::Csv.new(data, [:name, :email]).export
        end


        def users_to_export
          ParticipatorySpaceUsers.new(participatory_space, current_organization).query
        end
      end
    end
  end
end