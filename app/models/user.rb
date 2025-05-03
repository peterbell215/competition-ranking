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
