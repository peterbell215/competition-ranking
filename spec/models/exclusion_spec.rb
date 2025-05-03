require 'rails_helper'

RSpec.describe Exclusion, type: :model do
  describe 'validations' do
    let(:team1) { FactoryBot.create(:team, name: 'Team 1') }
    let(:team2) { FactoryBot.create(:team, name: 'Team 2') }

    it 'is valid with valid attributes' do
      exclusion = Exclusion.new(team: team1, excluded_team: team2)
      expect(exclusion).to be_valid
    end

    it 'is invalid without a team' do
      exclusion = Exclusion.new(excluded_team: team2)
      expect(exclusion).to be_invalid
      expect(exclusion.errors[:team_id]).to include("can't be blank")
    end

    it 'is invalid without an excluded team' do
      exclusion = Exclusion.new(team: team1)
      expect(exclusion).to be_invalid
      expect(exclusion.errors[:excluded_team_id]).to include("can't be blank")
    end

    it 'is invalid if a team tries to exclude itself' do
      exclusion = Exclusion.new(team: team1, excluded_team: team1)
      expect(exclusion).to be_invalid
      expect(exclusion.errors[:excluded_team_id]).to include("cannot be the same as the team")
    end

    it 'is invalid if the exclusion already exists' do
      Exclusion.create!(team: team1, excluded_team: team2)
      duplicate_exclusion = Exclusion.new(team: team1, excluded_team: team2)
      
      expect(duplicate_exclusion).to be_invalid
      expect(duplicate_exclusion.errors[:excluded_team_id]).to include("has already been taken")
    end
  end

  describe 'associations' do
    it 'belongs to team' do
      association = described_class.reflect_on_association(:team)
      expect(association.macro).to eq :belongs_to
    end

    it 'belongs to excluded_team' do
      association = described_class.reflect_on_association(:excluded_team)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:class_name]).to eq 'Team'
    end
  end
end
