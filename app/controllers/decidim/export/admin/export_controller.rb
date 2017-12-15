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
          @assemblies = Decidim::Assembly.where(organization: current_organization) if Object.const_defined?('Decidim::Assembly') # Check if the gem Decidim::Assembly is active
          @participatory_process + @assemblies
        end

        def export_data(data)
          Decidim::Export::Csv.new(data, [:name, :email]).export
        end

        def participatory_space
          space_id = request.query_parameters[:space_id]
          space_type = request.query_parameters[:space_type].constantize
          participatory_space = space_type.find(space_id)
        end

        def users_to_export
          if participatory_space
            (get_proposals_author +
             get_proposals_followers +
             get_users_who_vote +
             get_attended_users +
             get_attended_users +
             get_comment_author +
             get_comment_followers
            ).uniq
          else
            current_organization.users.uniq
          end
        end

        def get_proposals_features
          Decidim::Feature.where(manifest_name: :proposals, participatory_space: participatory_space)
        end

        def get_proposals
          proposals = Decidim::Proposals::Proposal.where(feature: get_proposals_features)
        end

        def get_proposals_author
           get_proposals.map(&:author)
        end

        def get_meeting
          features = Decidim::Feature.where(manifest_name: :meetings, participatory_space: participatory_space)
          Decidim::Meetings::Meeting.where(feature: features)
        end

        def get_attended_users
          get_meeting.map(&:registrations).flatten.map(&:user)
        end

        def get_users_who_vote
          users_ids = get_proposals.map(&:votes).flatten.map(&:author)
        end

        def get_proposals_followers
          followers_ids = []
          get_proposals.each{|p| followers_ids << p.follows.where.not(decidim_user_id: nil).map(&:decidim_user_id)}
          followers = Decidim::User.where(id: followers_ids.flatten)
          followers
        end

        def get_comment_author
          get_proposals.map(&:comments).flatten.map(&:author)
        end

        def get_comment_followers
          up_votes = get_proposals.map(&:comments).flatten.map(&:up_votes).flatten.map(&:author)
          down_votes = get_proposals.map(&:comments).flatten.map(&:down_votes).flatten.map(&:author)
          up_votes + down_votes
        end
      end
    end
  end
end