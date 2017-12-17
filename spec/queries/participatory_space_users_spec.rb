# frozen_string_literal: true

require "spec_helper"
require 'factories'

describe Decidim::Export::ParticipatorySpaceUsers do
  let(:organization) { create :organization }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:assembly) { create :assembly, organization: organization }
  let(:participatory_space) { assembly }
  let(:feature) { create(:feature, participatory_space: participatory_space) }
  let(:proposal_feature) { create(:feature, organization: organization, manifest_name: "proposals", participatory_space: participatory_space) }
  let(:meeting_feature) { create(:feature, manifest_name: "meetings", participatory_space: participatory_space) }
  let(:participatory_space2) { assembly }
  let(:meeting) { create(:meeting, feature: meeting_feature) }



  subject { described_class.new(participatory_space, organization) }

  describe "when params participatory space is present" do
    context "for proposal" do
      before do
        @proposal_author = create(:user, organization: organization)
        @proposal =  create(:proposal, feature: proposal_feature, author: @proposal_author)
      end

      it "get all users who posted a proposal" do
        expect(subject.query).to contain_exactly(@proposal_author)
      end

      it "get all users who follow a proposal" do
        follower = create(:user, organization: organization)
        @proposal.follows.create(user: follower)

        expect(subject.query).to contain_exactly(follower, @proposal_author)
      end

      it "get all users who vote for a proposal" do
        proposal_voter = create(:user, organization: organization)
        @proposal.votes.create(author: proposal_voter)

        expect(subject.query).to contain_exactly(proposal_voter, @proposal_author)
      end
    end

    context "for comment" do
      before do
        @commentable = create(:dummy_resource, feature: feature)
        @commenter = create(:user, organization: organization)
        @comment = @commentable.comments.create(body: "My comment", author: @commenter, root_commentable: @commentable)
      end

      it "get all users who posted a comment" do
        expect(subject.query).to contain_exactly(@commenter)
      end

      it "get all users who voted for a comment" do
        comment_downvoter = create(:user, organization: organization)
        comment_upvoter = create(:user, organization: organization)
        @comment.down_votes.create(author: comment_downvoter)
        @comment.up_votes.create(author: comment_upvoter)

        expect(subject.query).to contain_exactly(@commenter, comment_downvoter, comment_upvoter)
      end
    end
  end

  context "for meeting" do
    it "get all users who registered for an event" do
      attended = create(:user, organization: organization)
      meeting.registrations.create(user: attended)

      expect(subject.query).to contain_exactly(attended)
    end
  end

  describe "when params participatory space is not present" do
    it "get all users from organization" do
      proposal_author = create(:user, organization: organization)
      proposal =  create(:proposal, feature: proposal_feature, author: proposal_author)

      follower = create(:user, organization: organization)
      proposal.follows.create(user: follower)

      proposal_voter = create(:user, organization: organization)
      proposal.votes.create(author: proposal_voter)

      commentable = create(:dummy_resource, feature: feature)
      commenter = create(:user, organization: organization)
      comment = commentable.comments.create!(body: "My comment", author: commenter, root_commentable: commentable)

      comment_downvoter = create(:user, organization: organization)
      comment_upvoter = create(:user, organization: organization)
      comment.down_votes.create(author: comment_downvoter)
      comment.up_votes.create(author: comment_upvoter)


      attended = create(:user, organization: organization)
      meeting.registrations.create(user: attended)

      expect(subject.query).to contain_exactly(proposal_author, follower, proposal_voter, commenter, comment_downvoter, comment_upvoter, attended)
    end
  end
end
