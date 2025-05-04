require 'rails_helper'

RSpec.describe User, type: :model do
  let(:team) { FactoryBot.create(:team) }

  describe "validations" do
    context "when user is a team_member" do
      it "is invalid without a team" do
        user = FactoryBot.build(:team_member, team: nil)

        expect(user).to be_invalid
        expect(user.errors[:team_id]).to include("must be present for team members")
      end

      it "is valid with a team" do
        user = FactoryBot.build(:team_member, team: team)

        expect(user).to be_valid
      end
    end

    context "when user is a judge" do
      it "is valid without a team" do
        user = FactoryBot.build(:judge)

        expect(user).to be_valid
      end

      it "is invalid with a team" do
        user = FactoryBot.build(:judge, team: team)

        expect(user).to be_invalid
        expect(user.errors[:team_id]).to include("must not be present for judges or admins")
      end
    end

    context "when user is an admin" do
      it "is valid without a team" do
        user = FactoryBot.build(:admin)

        expect(user).to be_valid
      end

      it "is invalid with a team" do
        user = FactoryBot.build(:admin, team: team)

        expect(user).to be_invalid
        expect(user.errors[:team_id]).to include("must not be present for judges or admins")
      end
    end
  end

  describe "#available_teams" do
    let!(:team1) { FactoryBot.create(:team) }
    let!(:team2) { FactoryBot.create(:team) }
    let!(:team3) { FactoryBot.create(:team) }

    context "when user is a team member" do
      subject(:user) { FactoryBot.create(:team_member, team: team1) }

      it "returns all teams except their own team" do
        available_teams = user.available_teams

        expect(available_teams).to include(team2, team3)
        expect(available_teams).not_to include(team1)
        expect(available_teams.count).to eq(2)
      end

      it "doesn't return teams they are excluded from" do
        # Create exclusion for this user from team3
        FactoryBot.create(:exclusion, team: user.team, excluded_team: team3)

        available_teams = user.available_teams

        expect(available_teams).to include(team2)
        expect(available_teams).not_to include(team1, team3)
        expect(available_teams.count).to eq(1)
      end
    end

    context "when user is a judge" do
      subject(:user) { FactoryBot.create(:judge) }

      it "returns all teams" do
        available_teams = user.available_teams

        expect(available_teams).to include(team1, team2, team3)
        expect(available_teams.count).to eq(3)
      end
    end

    context "when user is an admin" do
      subject(:user) { FactoryBot.create(:admin) }

      it "returns all teams" do
        available_teams = user.available_teams

        expect(available_teams).to include(team1, team2, team3)
        expect(available_teams.count).to eq(3)
      end
    end
  end
end
