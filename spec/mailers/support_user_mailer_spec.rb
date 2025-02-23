require "rails_helper"

RSpec.describe SupportUserMailer, type: :mailer do
  describe "#support_user_invitation" do
    context "when inviting a user to the claims service" do
      subject(:invite_email) { described_class.with(service: "claims").support_user_invitation(user) }

      let(:user) { create(:claims_support_user, first_name: "John", last_name: "Doe") }

      it "is addressed to the user's email and contains a link to the claims sign in url" do
        expect(invite_email.to).to contain_exactly(user.email)
        expect(invite_email.subject).to eq("Invitation to join Claim funding for mentors")
        expect(invite_email.body).to have_content <<~EMAIL
          Dear John Doe,

          You have been invited to join Claim funding for mentors.

          Sign in here http://claims.localhost:3000/sign-in
        EMAIL
      end
    end

    context "when inviting a user to the placements service" do
      subject(:invite_email) { described_class.with(service: "placements").support_user_invitation(user) }

      let(:user) { create(:placements_support_user, first_name: "John", last_name: "Doe") }

      it "is addressed to the user's email and contains a link to the placements sign in url" do
        expect(invite_email.to).to contain_exactly(user.email)
        expect(invite_email.subject).to eq("Invitation to join Manage school placements")
        expect(invite_email.body).to have_content <<~EMAIL
          Dear John Doe,

          You have been invited to join Manage school placements.

          Sign in here http://placements.localhost:3000/sign-in
        EMAIL
      end
    end
  end

  describe "#support_user_removal_notification" do
    context "when removing a user from the claims service" do
      subject(:removal_email) { described_class.with(service: "claims").support_user_removal_notification(user) }

      let(:user) { create(:claims_support_user, first_name: "John", last_name: "Doe") }

      it "is addressed to the user's email and contains a link to the claims sign in url" do
        expect(removal_email.to).to contain_exactly(user.email)
        expect(removal_email.subject).to eq("You have been removed from Claim funding for mentors")
        expect(removal_email.body).to have_content <<~EMAIL
          Dear John Doe,

          You have been removed from Claim funding for mentors.
        EMAIL
      end
    end

    context "when removing a user from the placements service" do
      subject(:removal_email) { described_class.with(service: "placements").support_user_removal_notification(user) }

      let(:user) { create(:placements_support_user, first_name: "John", last_name: "Doe") }

      it "is addressed to the user's email and contains a link to the placements sign in url" do
        expect(removal_email.to).to contain_exactly(user.email)
        expect(removal_email.subject).to eq("You have been removed from Manage school placements")
        expect(removal_email.body).to have_content <<~EMAIL
          Dear John Doe,

          You have been removed from Manage school placements.
        EMAIL
      end
    end
  end
end
