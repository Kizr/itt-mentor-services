require "rails_helper"

RSpec.describe SupportUser::Remove do
  include ActiveJob::TestHelper

  describe ".call" do
    subject(:remove_support_user) { described_class.call(support_user:) }

    context "when given a valid Support User" do
      let(:support_user) { build(:claims_support_user) }

      it "returns true" do
        expect(remove_support_user).to be(true)
      end

      it "removes a user" do
        expect { remove_support_user }.to change { User.with_discarded.discarded.count }.by(1)
      end

      it "enqueues an invitation email" do
        expect { remove_support_user }.to change(enqueued_jobs, :size).by(1)
      end
    end

    context "when given a discarded Support User" do
      let(:support_user) { build(:claims_support_user, :discarded) }

      it "returns true" do
        expect(remove_support_user).to be(nil)
      end

      it "removes a user" do
        expect { remove_support_user }.to change { User.with_discarded.discarded.count }.by(0)
      end

      it "enqueues an invitation email" do
        expect { remove_support_user }.to change(enqueued_jobs, :size).by(0)
      end
    end
  end
end
