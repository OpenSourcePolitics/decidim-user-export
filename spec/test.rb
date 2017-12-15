require "spec_helper"

describe Decidim::Export do

  let(:feature) { proposal.feature }
  let(:proposal) { create(:proposal) }
  # let(:comment) { create :comment }
  let(:organization) { create :organization, available_locales: [:en] }
  let(:user) { create(:user, organization: organization) }
  let(:participatory_process1) { create :participatory_process, organization: organization }
  let(:participatory_process2) { create(:participatory_process, organization: organization) }

  it "returns all users wich created a proposal" do
    expect get_proposals_author(participatory_process1.id).to eq user
  end
end