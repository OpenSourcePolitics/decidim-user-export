# frozen_string_literal: true

require "spec_helper"
require 'factories'

describe Decidim::Export::ParticipatorySpaceUsers do
  let(:organization) { create :organization }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:assembly) { create :assembly, organization: organization }
  let(:participatory_space) { participatory_process }
  let(:component) { create(:component, participatory_space: participatory_space) }
  let(:proposal_component) { create(:component, organization: organization, manifest_name: "proposals", participatory_space: participatory_space) }
  let(:meeting_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_space) }
  let(:meeting) { create(:meeting, component: meeting_component) }

  let(:participatory_process2) { create(:participatory_process, organization: organization) }
  let(:participatory_space2) { participatory_process2 }
  let(:proposal_component2) { create(:component, organization: organization, manifest_name: "proposals", participatory_space: participatory_space2) }
  let(:component2) { create(:component, participatory_space: participatory_space2) }
  let(:meeting_component2) { create(:component, manifest_name: "meetings", participatory_space: participatory_space2) }
  let(:meeting2) { create(:meeting, component: meeting_component2) }

  describe "when params participatory space is present" do
    subject { described_class.new(participatory_space, organization) }

    context "for proposal" do
      before do
        @proposal_author = create(:user, organization: organization)
        @proposal =  create(:proposal, component: proposal_component, author: @proposal_author)

        # Partcipant from other participatory_space
        @proposal_author2 = create(:user, organization: organization)
        @proposal2 =  create(:proposal, component: proposal_component2, author: @proposal_author2)

      end

      it "get all users who posted a proposal" do
        expect(subject.query).to contain_exactly(@proposal_author)
      end

      it "get all users who follow a proposal" do
        follower = create(:user, organization: organization)
        @proposal.follows.create(user: follower)

        # Partcipant from other participatory_space
        follower2 = create(:user, organization: organization)
        @proposal2.follows.create(user: follower2)

        expect(subject.query).to contain_exactly(follower, @proposal_author)
      end

      it "get all users who vote for a proposal" do
        proposal_voter = create(:user, organization: organization)
        @proposal.votes.create(author: proposal_voter)

        # Partcipant from other participatory_space
        proposal_voter2 = create(:user, organization: organization)
        @proposal2.votes.create(author: proposal_voter2)

        expect(subject.query).to contain_exactly(proposal_voter, @proposal_author)
      end
    end

    context "for comment" do
      before do
        @commentable = create(:dummy_resource, component: component)
        @commenter = create(:user, organization: organization)
        @comment = @commentable.comments.create(body: "My comment", author: @commenter, root_commentable: @commentable)

        # Partcipant from other participatory_space
        @commentable2 = create(:dummy_resource, component: component2)
        @commenter2 = create(:user, organization: organization)
        @comment2 = @commentable2.comments.create(body: "My comment", author: @commenter2, root_commentable: @commentable2)
      end

      it "get all users who posted a comment" do
        expect(subject.query).to contain_exactly(@commenter)
      end

      it "get all users who voted for a comment" do
        comment_downvoter = create(:user, organization: organization)
        comment_upvoter = create(:user, organization: organization)
        @comment.down_votes.create(author: comment_downvoter)
        @comment.up_votes.create(author: comment_upvoter)

        # Partcipant from other participatory_space
        comment_downvoter2 = create(:user, organization: organization)
        comment_upvoter2 = create(:user, organization: organization)
        @comment2.down_votes.create(author: comment_downvoter2)
        @comment2.up_votes.create(author: comment_upvoter2)

        expect(subject.query).to contain_exactly(@commenter, comment_downvoter, comment_upvoter)
      end
    end

    context "for meeting" do
      it "get all users who registered for an event" do
        attended = create(:user, organization: organization)
        meeting.registrations.create(user: attended)

        # Partcipant from other participatory_space
        attended2 = create(:user, organization: organization)
        meeting2.registrations.create(user: attended2)

        expect(subject.query).to contain_exactly(attended)
      end
    end
  end

  describe "when params participatory space is not present" do
    subject { described_class.new(nil, organization) }

    it "get all users from organization" do
      proposal_author = create(:user, organization: organization)
      proposal =  create(:proposal, component: proposal_component, author: proposal_author)

      follower = create(:user, organization: organization)
      proposal.follows.create(user: follower)

      proposal_voter = create(:user, organization: organization)
      proposal.votes.create(author: proposal_voter)

      commentable = create(:dummy_resource, component: component)
      commentable_author = commentable.author
      commenter = create(:user, organization: organization)
      comment = commentable.comments.create!(body: "My comment", author: commenter, root_commentable: commentable)

      comment_downvoter = create(:user, organization: organization)
      comment_upvoter = create(:user, organization: organization)
      comment.down_votes.create(author: comment_downvoter)
      comment.up_votes.create(author: comment_upvoter)

      attended = create(:user, organization: organization)
      meeting.registrations.create(user: attended)

      # Partcipant from other participatory_space
      proposal_author2 = create(:user, organization: organization)
      proposal2 =  create(:proposal, component: proposal_component2, author: proposal_author2)
      follower2 = create(:user, organization: organization)
      proposal2.follows.create(user: follower2)
      proposal_voter2 = create(:user, organization: organization)
      proposal2.votes.create(author: proposal_voter2)
      commentable2 = create(:dummy_resource, component: component2)
      commentable_author2 = commentable2.author
      commenter2 = create(:user, organization: organization)
      comment2 = commentable2.comments.create(body: "My comment", author: commenter2, root_commentable: commentable2)
      comment_downvoter2 = create(:user, organization: organization)
      comment_upvoter2 = create(:user, organization: organization)
      comment2.down_votes.create(author: comment_downvoter2)
      comment2.up_votes.create(author: comment_upvoter2)
      attended2 = create(:user, organization: organization)
      meeting2.registrations.create(user: attended2)

      expect(subject.query).to contain_exactly(proposal_author, follower, proposal_voter, commentable_author, commenter, comment_downvoter, comment_upvoter, attended, proposal_author2, follower2, proposal_voter2, commentable_author2, commenter2, comment_downvoter2, comment_upvoter2, attended2)
    end
  end
end
