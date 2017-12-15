require "spec_helper"
require 'factories'

describe Decidim::Export do

  let(:feature) { proposal.feature }
  let(:proposal) { create(:proposal) }
  # let(:comment) { create :comment }
  let(:organization) { create :organization, available_locales: [:en] }
  let(:user) { create(:user, organization: organization) }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:assembly) { create :assembly, organization: organization }


  it "returns all participatory space" do
    expect participatory_process.to eq [participatory_process, assembly]
  end
end