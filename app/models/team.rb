class Team < ApplicationRecord
  # Associations
  has_many :users, dependent: :nullify
  has_many :rankings, dependent: :destroy
  
  # Exclusion associations
  has_many :exclusions, dependent: :destroy
  has_many :excluded_teams, through: :exclusions, source: :excluded_team

  has_many :inverse_exclusions, class_name: "Exclusion", foreign_key: "excluded_team_id", dependent: :destroy
  has_many :excluded_by_teams, through: :inverse_exclusions, source: :team

  # Validations
  validates :name, presence: true, uniqueness: true
  
  # Methods
  def can_rank?(other_team)
    self != other_team && !excluded_teams.include?(other_team)
  end
end
