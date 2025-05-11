require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'exclusion relationships' do
    let(:team_a) { create(:team, name: 'Team A') }
    let(:team_b) { create(:team, name: 'Team B') }
    let(:team_c) { create(:team, name: 'Team C') }

    before do
      # Team A excludes Team B
      create(:exclusion, team: team_a, excluded_team: team_b)

      # Team C excludes Team A
      create(:exclusion, team: team_c, excluded_team: team_a)
    end

    describe '#excluded_teams' do
      it 'returns teams that this team excludes' do
        expect(team_a.excluded_teams).to include(team_b)
        expect(team_a.excluded_teams).not_to include(team_c)

        expect(team_b.excluded_teams).to be_empty

        expect(team_c.excluded_teams).to include(team_a)
        expect(team_c.excluded_teams).not_to include(team_b)
      end
    end

    describe '#excluded_by_teams' do
      it 'returns teams that exclude this team' do
        expect(team_a.excluded_by_teams).to include(team_c)
        expect(team_a.excluded_by_teams).not_to include(team_b)

        expect(team_b.excluded_by_teams).to include(team_a)
        expect(team_b.excluded_by_teams).not_to include(team_c)

        expect(team_c.excluded_by_teams).to be_empty
      end
    end

    describe '#can_rank?' do
      it 'returns false for excluded teams' do
        expect(team_a.can_rank?(team_b)).to be false
        expect(team_c.can_rank?(team_a)).to be false
      end

      it 'returns true for non-excluded teams' do
        expect(team_a.can_rank?(team_c)).to be true
        expect(team_b.can_rank?(team_a)).to be true
        expect(team_b.can_rank?(team_c)).to be true
      end

      it 'returns false for self' do
        expect(team_a.can_rank?(team_a)).to be false
        expect(team_b.can_rank?(team_b)).to be false
        expect(team_c.can_rank?(team_c)).to be false
      end
    end
  end
end
