# frozen_string_literal: true

module Decidim
  module Export
    class ParticipatorySpaceUsers < Rectify::Query
      def initialize(participatory_space, organization)
        @participatory_space = participatory_space
        @organization = organization
      end

      def query
        if @participatory_space.nil?
          @organization.users.uniq

        else
          (get_proposals_author +
           get_proposals_followers +
           get_proposal_voters +
           get_attended_users +
           get_comment_author +
           get_comment_voters
          ).uniq
        end
      end

      def get_proposals
        components = @participatory_space.components.where(manifest_name: :proposals)
        Decidim::Proposals::Proposal.where(component: components)
      end

      def get_proposals_author
        get_proposals.map(&:author)
      end

      def get_meeting
        components = @participatory_space.components.where(manifest_name: :meetings)
        Decidim::Meetings::Meeting.where(component: components)
      end

      def get_attended_users
        get_meeting.map(&:registrations).flatten.map(&:user)
      end

      def get_proposal_voters
        get_proposals.map(&:votes).flatten.map(&:author)
      end

      def get_proposals_followers
        followers_ids = []

        get_proposals.each do |proposal|
          if proposal.follows.any?
            followers_ids << proposal.follows.map(&:user).map(&:id)
          end
        end

        followers = Decidim::User.where(id: followers_ids)
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
        organization_users = @organization.users

        root_commentables = Decidim::Comments::Comment.where(author: organization_users).map(&:root_commentable)

        commentable = []
        root_commentables.each do |root_commentable|
          if root_commentable.component.participatory_space == @participatory_space
            commentable << root_commentable
          end
        end
        commentable
      end
    end
  end
end
