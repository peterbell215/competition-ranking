class Ranking < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validates :user_id, presence: true
  validates :team_id, presence: true
  validates :category, presence: true
  
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Define categories as enum
  enum :category, { technical: 0, commercial: 1, overall: 2 }

  def self.update_rankings(user, category, team_ids)

  end
  
  # Class method to get average score for a team by category
  def self.average_score_by_category(team_id, category)
    where(team_id: team_id, category: category).average(:position)
  end
end
