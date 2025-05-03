class Ranking < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validates :user_id, presence: true
  validates :team_id, presence: true
  validates :category, presence: true
  validates :user_id, uniqueness: { scope: [:team_id, :category], message: "has already ranked this team in this category" }
  
  validates :merit, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10, allow_nil: true }

  # Define categories as enum
  enum category: {
    technical: 0,
    commercial: 1,
    overall: 2
  }

  def complete?
    merit.present?
  end
  
  # Class method to get total score for a team across all categories
  def self.total_score_for_team(team_id, user_id = nil)
    rankings = where(team_id: team_id)
    rankings = rankings.where(user_id: user_id) if user_id.present?
    rankings.sum(:merit)
  end
  
  # Class method to get average score for a team by category
  def self.average_score_by_category(team_id, category)
    where(team_id: team_id, category: category).average(:merit)
  end
end
