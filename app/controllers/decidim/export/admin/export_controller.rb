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
          participatory_process
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

        def participatory_process
          @participatory_process ||= Decidim::ParticipatoryProcess.where(organization: current_organization)
        end
        def export_data(data)
          Decidim::Export::Csv.new(data, [:name, :email]).export
        end

        def users_to_export
          process_id = request.query_parameters[:process_id]
          if process_id
            (get_proposals_author(process_id) +
             get_proposals_followers(process_id) +
             get_users_who_vote(process_id) +
             get_attended_users(process_id) +
             get_attended_users(process_id) +
             get_comment_author(process_id) +
             get_comment_followers(process_id)
            ).uniq
          else
            current_organization.users.uniq
          end
        end

        def get_proposals_author(process_id)
           get_proposals(process_id).map(&:author)
        end

        def get_proposals_features(process_id)
          Decidim::Feature.where(manifest_name: :proposals, participatory_space: process_id)
        end


        def get_proposals(process_id)
          proposals = Decidim::Proposals::Proposal.where(feature: get_proposals_features(process_id))
        end

        def get_meeting(process_id)
          features = Decidim::Feature.where(manifest_name: :meetings, participatory_space: process_id)
          Decidim::Meetings::Meeting.where(feature: features)
        end

        def get_attended_users(process_id)
          get_meeting(process_id).map(&:registrations).flatten.map(&:user)
        end

        def get_users_who_vote(process_id)
          users_ids = get_proposals(process_id).map(&:votes).flatten.map(&:author)
        end

        def get_proposals_followers(process_id)
          followers_ids = []
          get_proposals(process_id).each{|p| followers_ids << p.follows.where.not(decidim_user_id: nil).map(&:decidim_user_id)}
          followers = Decidim::User.where(id: followers_ids.flatten)
          followers
        end

        def get_comment_author(process_id)
          get_proposals(process_id).comments.map(&:author)
        end

        def get_comment_followers(process_id)
          up_votes = get_proposals(process_id).map(&:comments).flatten.map(&:up_votes).flatten.map(&:author)
          down_votes = get_proposals(process_id).map(&:comments).flatten.map(&:down_votes).flatten.map(&:author)
          up_votes + down_votes
        end
      end
    end
  end
end