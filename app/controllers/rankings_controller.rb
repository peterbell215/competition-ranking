# app/controllers/rankings_controller.rb
class RankingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @teams = current_user.available_teams
    @technical_rankings = current_user.find_or_create_rankings(:technical)
    @commercial_rankings = current_user.find_or_create_rankings(:commercial)
    @overall_rankings = current_user.find_or_create_rankings(:overall)
  end

  def update_rankings
    rankings_by_category = params.require(:rankings)

    rankings_by_category.each_pair do |category, team_rankings|
      Ranking.update_rankings(current_user, category, team_rankings)
    end
    render json: { success: true, notice: "Rankings saved successfully!" }
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end
end
