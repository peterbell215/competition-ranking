class ExclusionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin_or_team_owner, only: [:create, :destroy]

  # POST /exclusions
  def create
    @team = Team.find(params[:team_id])
    @excluded_team = Team.find(params[:excluded_team_id])
    
    @exclusion = Exclusion.new(team: @team, excluded_team: @excluded_team)

    if @exclusion.save
      redirect_to edit_team_path(@team), notice: "#{@excluded_team.name} excluded successfully."
    else
      redirect_to edit_team_path(@team), alert: "Failed to exclude team: #{@exclusion.errors.full_messages.join(', ')}"
    end
  end

  # DELETE /exclusions/:id
  def destroy
    @exclusion = Exclusion.find(params[:id])
    team = @exclusion.team
    excluded_team_name = @exclusion.excluded_team.name
    
    if @exclusion.destroy
      redirect_to edit_team_path(team), notice: "Exclusion of #{excluded_team_name} removed successfully."
    else
      redirect_to edit_team_path(team), alert: "Failed to remove exclusion."
    end
  end

  private

  def authorize_admin_or_team_owner
    # For create action
    if params[:team_id].present?
      team = Team.find(params[:team_id])
    # For destroy action
    elsif params[:id].present?
      team = Exclusion.find(params[:id]).team
    end

    unless current_user.admin? || (current_user.team_member? && current_user.team_id == team.id)
      flash[:alert] = "You are not authorized to modify exclusions for this team."
      redirect_to teams_path
    end
  end
end
