# == Schema Information
#
# Table name: providers
#
#  id                 :uuid             not null, primary key
#  accredited         :boolean          default(FALSE)
#  address1           :string
#  address2           :string
#  address3           :string
#  city               :string
#  code               :string           not null
#  county             :string
#  email_address      :string
#  name               :string           not null
#  placements_service :boolean          default(FALSE)
#  postcode           :string
#  provider_type      :enum             not null
#  telephone          :string
#  town               :string
#  ukprn              :string
#  urn                :string
#  website            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_providers_on_code                (code) UNIQUE
#  index_providers_on_placements_service  (placements_service)
#
require "rails_helper"

RSpec.describe Provider, type: :model do
  context "with associations" do
    it { is_expected.to have_many(:user_memberships) }
    it { is_expected.to have_many(:users).through(:user_memberships) }
    it { is_expected.to have_many(:mentor_trainings) }
  end

  context "with validations" do
    subject(:test_provider) { build(:provider) }

    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:name) }

    it do
      expect(test_provider).to validate_uniqueness_of(
        :code,
      ).case_insensitive
    end

    it { is_expected.to allow_values("scitt", "lead_school", "university").for(:provider_type) }
  end

  context "with scopes" do
    describe "#accredited" do
      let!(:accredited_provider) { create(:provider, accredited: true) }
      let!(:non_accredited_provider) { create(:provider) }

      it "only returns the providers which have been onboarded (placements: true)" do
        expect(described_class.accredited).to contain_exactly(accredited_provider)
        expect(described_class.accredited).not_to include(non_accredited_provider)
      end
    end

    describe "#placements_service" do
      it "only returns placements providers" do
        create(:provider)
        placements_provider = create(:provider, :placements)

        expect(described_class.placements_service).to contain_exactly(placements_provider)
      end
    end

    describe "#private_beta_providers" do
      it "returns only the private beta providers" do
        provider1 = create(:provider, :best_practice_network)
        provider2 = create(:provider, :niot)
        provider3 = create(:provider)

        expect(described_class.private_beta_providers).to eq([provider1, provider2])
        expect(described_class.private_beta_providers).not_to include(provider3)
      end
    end
  end
end
