require 'rails_helper'

RSpec.describe Ranking, type: :model do
  describe ".calculate_results_for_user_type_and_category" do
    let!(:team1) { create(:team, name: "Team 1") }
    let!(:team2) { create(:team, name: "Team 2") }
    let!(:team3) { create(:team, name: "Team 3") }
    
    let!(:team_member1) { create(:team_member, team: team1) }
    let!(:team_member2) { create(:team_member, team: team2) }
    let!(:team_member3) { create(:team_member, team: team3) }
    
    let!(:judge1) { create(:judge) }
    let!(:judge2) { create(:judge) }
    let!(:admin1) { create(:admin) }
    
    # Create sample rankings for team members
    before do
      # Team member rankings
      create(:technical_ranking, user: team_member1, team: team2, position: 1) # Team member 1 ranks Team 2 as #1
      create(:technical_ranking, user: team_member1, team: team3, position: 2) # Team member 1 ranks Team 3 as #2
      
      create(:technical_ranking, user: team_member2, team: team1, position: 1) # Team member 2 ranks Team 1 as #1
      create(:technical_ranking, user: team_member2, team: team3, position: 2) # Team member 2 ranks Team 3 as #2
      
      create(:technical_ranking, user: team_member3, team: team1, position: 1) # Team member 3 ranks Team 1 as #1
      create(:technical_ranking, user: team_member3, team: team2, position: 2) # Team member 3 ranks Team 2 as #2
      
      # Judge and admin rankings
      create(:technical_ranking, user: judge1, team: team1, position: 2) # Judge 1 ranks Team 1 as #2
      create(:technical_ranking, user: judge1, team: team2, position: 3) # Judge 1 ranks Team 2 as #3
      create(:technical_ranking, user: judge1, team: team3, position: 1) # Judge 1 ranks Team 3 as #1
      
      create(:technical_ranking, user: judge2, team: team1, position: 3) # Judge 2 ranks Team 1 as #3
      create(:technical_ranking, user: judge2, team: team2, position: 1) # Judge 2 ranks Team 2 as #1
      create(:technical_ranking, user: judge2, team: team3, position: 2) # Judge 2 ranks Team 3 as #2
      
      create(:technical_ranking, user: admin1, team: team1, position: 1) # Admin ranks Team 1 as #1
      create(:technical_ranking, user: admin1, team: team2, position: 2) # Admin ranks Team 2 as #2
      create(:technical_ranking, user: admin1, team: team3, position: 3) # Admin ranks Team 3 as #3
    end
    
    context "when user_type is :team_member" do
      it "returns average rankings for team members only" do
        teams = [team1, team2, team3]
        results = Ranking.calculate_results_for_user_type_and_category(teams, :team_member, :technical)

        # Convert results to a hash for easier testing
        results_hash = {}
        results.each { |team, avg| results_hash[team.id] = avg }

        # Expected team member averages:
        # Team 1: (1 + 1) / 2 = 1.0 (ranked by member2 and member3)
        # Team 2: (1 + 2) / 2 = 1.5 (ranked by member1 and member3)
        # Team 3: (2 + 2) / 2 = 2.0 (ranked by member1 and member2)

        expect(results_hash[team1.id]).to be_within(0.01).of(1.0)
        expect(results_hash[team2.id]).to be_within(0.01).of(1.5)
        expect(results_hash[team3.id]).to be_within(0.01).of(2.0)

        # Check that results are sorted by position (lowest first)
        expect(results.first[0]).to eq(team1)
        expect(results.second[0]).to eq(team2)
        expect(results.third[0]).to eq(team3)
      end
    end
    
    context "when user_type is an array of [:judge, :admin]" do
      it "returns average rankings for judges and admins combined" do
        teams = [team1, team2, team3]
        results = Ranking.calculate_results_for_user_type_and_category(teams, [:judge, :admin], :technical)

        # Convert results to a hash for easier testing
        results_hash = {}
        results.each { |team, avg| results_hash[team.id] = avg }

        # Expected judge/admin averages:
        # Team 1: (2 + 3 + 1) / 3 = 2.0 (judge1, judge2, admin1)
        # Team 2: (3 + 1 + 2) / 3 = 2.0 (judge1, judge2, admin1)
        # Team 3: (1 + 2 + 3) / 3 = 2.0 (judge1, judge2, admin1)

        expect(results_hash[team1.id]).to be_within(0.01).of(2.0)
        expect(results_hash[team2.id]).to be_within(0.01).of(2.0)
        expect(results_hash[team3.id]).to be_within(0.01).of(2.0)
      end
    end
    
    context "when one team has no rankings" do
      it "excludes teams with no rankings" do
        # Create a new team with no rankings
        team4 = create(:team, name: "Team 4")

        teams = [team1, team2, team3, team4]
        results = Ranking.calculate_results_for_user_type_and_category(teams, :team_member, :technical)

        # Check that team4 is not in the results (it will have nil result and be skipped)
        team_ids_with_values = results.reject { |_, value| value.nil? }.map { |team, _| team.id }
        expect(team_ids_with_values).not_to include(team4.id)
      end
    end
    
    context "with different category" do
      before do
        # Create some commercial rankings
        create(:commercial_ranking, user: team_member1, team: team2, position: 2) # Different from technical
        create(:commercial_ranking, user: team_member2, team: team3, position: 1) # Different from technical
      end

      it "only returns rankings for the specified category" do
        teams = [team1, team2, team3]
        technical_results = Ranking.calculate_results_for_user_type_and_category(teams, :team_member, :technical)
        commercial_results = Ranking.calculate_results_for_user_type_and_category(teams, :team_member, :commercial)

        # These should be different based on our test data
        technical_hash = {}
        technical_results.each { |team, avg| technical_hash[team.id] = avg }

        commercial_hash = {}
        commercial_results.each { |team, avg| commercial_hash[team.id] = avg }

        # Not all teams are ranked in commercial
        teams_with_technical_values = technical_results.reject { |_, v| v.nil? }.length
        teams_with_commercial_values = commercial_results.reject { |_, v| v.nil? }.length

        expect(teams_with_technical_values).to be > teams_with_commercial_values

        # Team 2's position is different in technical vs commercial
        if technical_hash[team2.id] && commercial_hash[team2.id]
          expect(technical_hash[team2.id]).not_to eq(commercial_hash[team2.id])
        end
      end
    end
  end

  describe '.average_results_for_category' do
    let!(:team1) { FactoryBot.create(:team) }
    let!(:team2) { FactoryBot.create(:team) }
    let!(:team3) { FactoryBot.create(:team) }

    context 'when both arrays have values for all teams' do
      it 'returns averages of the values' do
        teams = [team1, team2, team3]
        team_member_results = [
          [team1, 1.0],
          [team2, 2.0],
          [team3, 3.0]
        ]
        judge_admin_results = [
          [team1, 2.0],
          [team2, 3.0],
          [team3, 1.0]
        ]

        expected_result = [
          [team1, 1.5],  # (1.0 + 2.0) / 2 = 1.5
          [team3, 2.0],  # (3.0 + 1.0) / 2 = 2.0
          [team2, 2.5]   # (2.0 + 3.0) / 2 = 2.5
        ]

        result = Ranking.average_results_for_category(teams, team_member_results, judge_admin_results)
        expect(result).to eq(expected_result)
      end
    end

    context 'when one array is missing a team' do
      it 'uses only the available value' do
        teams = [team1, team2, team3]
        team_member_results = [
          [team1, 1.0],
          [team3, 3.0]
        ]
        judge_admin_results = [
          [team1, 2.0],
          [team2, 3.0],
          [team3, 1.0]
        ]

        expected_result = [
          [team1, 1.5],  # (1.0 + 2.0) / 2 = 1.5
          [team3, 2.0],  # (3.0 + 1.0) / 2 = 2.0
          [team2, 3.0]   # Only judge_admin_results has team2
        ]

        result = Ranking.average_results_for_category(teams, team_member_results, judge_admin_results)
        expect(result).to eq(expected_result)
      end
    end

    context 'when both arrays are missing a team' do
      it 'includes the team with nil value in results' do
        team4 = FactoryBot.create(:team, name: 'Team 4')
        teams = [team1, team2, team3, team4]

        team_member_results = [
          [team1, 1.0],
          [team2, 2.0],
          [team3, 3.0]
        ]
        judge_admin_results = [
          [team1, 2.0],
          [team2, 3.0],
          [team3, 1.0]
        ]

        result = Ranking.average_results_for_category(teams, team_member_results, judge_admin_results)

        # team4 should be in the results with a nil value
        team4_result = result.find { |team, _| team == team4 }

        # Check that team4 is included but its value is nil
        expect(team4_result).not_to be_nil
        expect(team4_result[1]).to be_nil
      end
    end

    context 'when only one array has a nil value' do
      it 'uses only the non-nil value' do
        teams = [team1, team2, team3]
        team_member_results = [
          [team1, 1.0],
          [team3, 3.0]
        ]
        judge_admin_results = [
          [team1, 2.0],
          [team2, 3.0],
          [team3, 1.0]
        ]

        expected_result = [
          [team1, 1.5],  # (1.0 + 2.0) / 2 = 1.5
          [team3, 2.0],  # (3.0 + 1.0) / 2 = 2.0
          [team2, 3.0]   # Only judge_admin_results has a value for team2
        ]

        result = Ranking.average_results_for_category(teams, team_member_results, judge_admin_results)
        expect(result).to eq(expected_result)
      end
    end

    context 'when both arrays are empty' do
      it 'returns all teams with nil values' do
        teams = [team1, team2, team3]
        team_member_results = []
        judge_admin_results = []

        result = Ranking.average_results_for_category(teams, team_member_results, judge_admin_results)

        # All teams should be listed but with nil values
        expect(result.length).to eq(teams.length)
        expect(result.all? { |_team, value| value.nil? }).to be_truthy
      end
    end
  end
end
