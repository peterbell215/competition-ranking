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

    Team.all.each do |team|
      # Get all rankings for this team in this category
      rankings = Ranking.where(team: team, category: category)
      
      # Skip if no rankings for this team
      next if rankings.empty?
      
      # Calculate team member average position
      team_member_rankings = rankings.joins(:user).where(users: { user_type: :team_member })
      team_member_avg = team_member_rankings.average(:position)&.to_f || 0
      
      # Calculate judge/admin average position
      judge_admin_rankings = rankings.joins(:user).where(users: { user_type: [:judge, :admin] })
      judge_admin_avg = judge_admin_rankings.average(:position)&.to_f || 0
      
      # Calculate combined average (simple average of the two averages)
      combined_avg = (team_member_avg + judge_admin_avg) / 2.0
      
      # Add to results array
      results << {
        team: team,
        team_member_avg: team_member_avg,
        judge_admin_avg: judge_admin_avg,
        combined_avg: combined_avg
      }
    end
    
    # Return results sorted by combined average
    results
  end
end