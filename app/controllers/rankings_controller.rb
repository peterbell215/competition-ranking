# app/controllers/rankings_controller.rb
class RankingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @teams = current_user.available_teams
    @technical_rankings = current_user.find_or_create_rankings(:technical)
    @commercial_rankings = current_user.find_or_create_rankings(:commercial)
    @overall_rankings = current_user.find_or_create_rankings(:overall)
  end

  def update



    begin
      ActiveRecord::Base.transaction do
        params[:rankings].each do |category, team_rankings|
          team_rankings.each_with_index do |team_id, position|
            ranking = Ranking.find_or_initialize_by(
              user: current_user,
              team_id: team_id,
              category: category
            )
            ranking.merit = 10 - position # Higher position = higher merit (10 to 1)
            ranking.save!
          end
        end
      end
      render json: { success: true }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
