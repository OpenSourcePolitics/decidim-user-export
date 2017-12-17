# frozen_string_literal: true

module Decidim
  module Export
    # This query class filters published assemblies given an organization.
    class ParticipatorySpaceUsers < Rectify::Query
      def initialize(participatory_space, organization)
        @participatory_space = participatory_space
        @organization = organization
      end

      def query
        if @participatory_space
          (get_proposals_author +
           get_proposals_followers +
           get_proposal_voters +
           get_attended_users +
           get_comment_author +
           get_comment_voters
          ).uniq
        else
          @organization.users.uniq
        end
      end

     def get_proposals_features
        Decidim::Feature.where(manifest_name: :proposals, participatory_space: @participatory_space)
      end

      def get_proposals
        proposals = Decidim::Proposals::Proposal.where(feature: get_proposals_features)
      end

      def get_proposals_author
         get_proposals.map(&:author)
      end

      def get_meeting
        features = Decidim::Feature.where(manifest_name: :meetings, participatory_space: @participatory_space)
        Decidim::Meetings::Meeting.where(feature: features)
      end

      def get_attended_users
        get_meeting.map(&:registrations).flatten.map(&:user)
      end

      def get_proposal_voters
        get_proposals.map(&:votes).flatten.map(&:author)
      end

      def get_proposals_followers
        followers_ids = []
        get_proposals.each{|p| followers_ids << p.follows.where.not(decidim_user_id: nil).map(&:decidim_user_id)}
        followers = Decidim::User.where(id: followers_ids.flatten)
        followers
      end

      def get_comment_author
        get_commentable.map(&:comments).flatten.map(&:author)
      end

      def get_comment_voters
        up_votes = get_commentable.map(&:comments).flatten.map(&:up_votes).flatten.map(&:author)
        down_votes = get_commentable.map(&:comments).flatten.map(&:down_votes).flatten.map(&:author)
        up_votes + down_votes
      end

      def get_commentable

        features = Decidim::Feature.where( participatory_space: @participatory_space).uniq

        commentable_features = Decidim::Comments::Comment.all.map(&:root_commentable).map(&:feature)

        organization_users = @organization.users
        root_commentable = Decidim::Comments::Comment.where(author: organization_users).map(&:root_commentable)


        commentable = []
        root_commentable.each do |rc|
          if commentable_features.include?(rc.feature)
            commentable << rc
          end
        end
        commentable
      end
    end
  end
end
