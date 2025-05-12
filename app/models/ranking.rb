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
    team_ids.each_with_index do |team_id, position|
      Ranking.where(user_id: user.id, team_id: team_id, category: category).update!(position: position + 1)
    end
  end

  def self.calculate_results_for_user_type_and_category(user_type, category)
    results = {}

    Team.all.each do |team|
      # Get all rankings for this team in this category
      average_position = Ranking.where(team: team, category: category).joins(:user).where(users: { user_type: user_type }).average(:position)

      # Skip if no rankings for this team
      results[team] = average_position if average_position
    end

    # Return results sorted by position (lower is better)
    results.sort_by { |_team, average_position| average_position || Float::INFINITY }
  end

  def self.average_results_for_category(team_member_results, judge_admin_results)
    results = {}

    Team.all.each do |team|
      results[team] = if team_member_results[team] && judge_admin_results[team]
                        (team_member_results[team] + judge_admin_results[team]) / 2.0
                      else
                        judge_admin_results[team] || team_member_results[team]
                      end
    end

    # Return results sorted by position (lower is better)
    results.sort_by { |_team, average_position| average_position || Float::INFINITY } .to_h
  end
end
