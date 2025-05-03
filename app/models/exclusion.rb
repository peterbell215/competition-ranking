class Exclusion < ApplicationRecord
  # Associations
  belongs_to :team
  belongs_to :excluded_team, class_name: 'Team'
  
  # Validations
  validates :team_id, presence: true
  validates :excluded_team_id, presence: true
  validates :excluded_team_id, uniqueness: { scope: :team_id }
  validate :cannot_exclude_self
  
  private
  
  def cannot_exclude_self
    if team_id == excluded_team_id
      errors.add(:excluded_team_id, "cannot be the same as the team")
    end
  end
end
