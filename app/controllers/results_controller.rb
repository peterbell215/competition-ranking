# app/controllers/results_controller.rb
class ResultsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Get all teams
    @teams = Team.all
    
    # Calculate rankings for each category
    @technical_results = calculate_results_for_category(:technical)
    @commercial_results = calculate_results_for_category(:commercial)
    @overall_results = calculate_results_for_category(:overall)
  end

  private

  def calculate_results_for_category(category)
    results = []
    
    # Get team member and judge/admin average rankings
    team_member_results = Ranking.calculate_results_for_user_type_and_category(:team_member, category)
    judge_admin_results = Ranking.calculate_results_for_user_type_and_category([:judge, :admin], category)
    
    # Convert to hash for easier lookups
    team_member_averages = {}
    team_member_results.each { |team, avg| team_member_averages[team.id] = avg }
    
    judge_admin_averages = {}
    judge_admin_results.each { |team, avg| judge_admin_averages[team.id] = avg }
    
    # Create combined results
    combined_teams = (team_member_averages.keys + judge_admin_averages.keys).uniq
    
    combined_teams.each do |team_id|
      team = Team.find(team_id)
      team_member_avg = team_member_averages[team_id]
      judge_admin_avg = judge_admin_averages[team_id]
      
      # Only include in results if at least one average exists
      if team_member_avg || judge_admin_avg
        # Calculate combined average (if both exist, otherwise use the one that exists)
        combined_avg = if team_member_avg && judge_admin_avg
                        (team_member_avg + judge_admin_avg) / 2.0
                      elsif team_member_avg
                        team_member_avg
                      else
                        judge_admin_avg
                      end
        
        results << {
          team: team,
          team_member_avg: team_member_avg,
          judge_admin_avg: judge_admin_avg,
          combined_avg: combined_avg
        }
      end
    end
    
    results
  end
end