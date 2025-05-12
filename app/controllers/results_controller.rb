# app/controllers/results_controller.rb
class ResultsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Get all teams
    @teams = Team.all

    @team_members_rankings_by_category = {}
    @judges_and_admin_rankings_by_category = {}
    @combined_rankings_by_category = {}

    # Calculate rankings for each category of scoring and for the two cohorts
    [:technical, :commercial, :overall].each do |category|
      @team_members_rankings_by_category[category] =
        Ranking.calculate_results_for_user_type_and_category(@teams, :team_member, category)
      @judges_and_admin_rankings_by_category[category] =
        Ranking.calculate_results_for_user_type_and_category(@teams, [:judge, :admin], category)
      @combined_rankings_by_category[category] =
        Ranking.average_results_for_category(@teams, @team_members_rankings_by_category[category], @judges_and_admin_rankings_by_category[category])
    end
  end
end
