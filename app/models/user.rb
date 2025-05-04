class User < ApplicationRecord
  # Include default devise modules. Others available are:
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :validatable

  after_create :send_invitation_email

  # Associations
  belongs_to :team, optional: true
  has_many :rankings, dependent: :destroy

  # Enums
  enum :user_type, { team_member: 0, judge: 1, admin: 2 }

  # Validations
  validates :name, presence: true
  validates :user_type, presence: true
  validate :team_member_must_have_team
  validate :judges_and_admins_must_not_have_team

  # Scopes
  scope :judges, -> { where(user_type: :judge) }
  scope :admins, -> { where(user_type: :admin) }
  scope :team_members, -> { where(user_type: :team_member) }

  # Returns a list of teams available for the current user to rank
  #
  # @return [ActiveRecord::Relation<Team>] Collection of available teams
  #   - For team members: All teams except their own team and any teams they're excluded from ranking
  #   - For judges and admins: All teams
  def available_teams
    teams = Team.all

    if self.team_member?
      # Filter out user's own team
      teams = teams.where.not(id: self.team_id)

      # Filter out teams excluded from ranking
      excluded_team_ids = Exclusion.where(team_id: self.team_id).pluck(:excluded_team_id)
      teams = teams.where.not(id: excluded_team_ids) if excluded_team_ids.any?
    end

    teams
  end

  def find_or_create_rankings(category)
    rankings = self.rankings.where(category: category).order(:position).includes(:team).to_a

    # If the number of teams stored in rankings is less than the available teams, we need to add the missing teams.
    if rankings.count < available_teams.count
      additional_team_ids = (available_teams.ids - rankings.pluck(:team_id)).shuffle!
      additional_positions = ((rankings.count + 1)..).each

      additional_team_ids.each do |team_id|
        rankings << Ranking.create(user: self, team_id: team_id, category: category, position: additional_positions.next)
      end
    end

    rankings
  end

  private

  def team_member_must_have_team
    if team_member? && team_id.blank?
      errors.add(:team_id, "must be present for team members")
    end
  end

  def judges_and_admins_must_not_have_team
    if (judge? || admin?) && team_id.present?
      errors.add(:team_id, "must not be present for judges or admins")
    end
  end

  def send_invitation_email
    # Skip if this is an invited user (Devise Invitable will handle it)
    return if invitation_token.present?

    # Generate invitation token and send invitation email
    invite!
  end
end
