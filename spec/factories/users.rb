FactoryBot.define do
  factory :user do
    skip_invitation     { true }
    password            { "password" }

    factory :team_member do
      sequence(:name)   { |n| "Team Member #{n}" }
      sequence(:email)  { |n| "team.member#{n}@modaxo.com" }
      user_type         { :team_member }
      team
    end

    factory :judge do
      sequence(:name)   { |n| "Judge #{n}" }
      sequence(:email)  { |n| "judge#{n}@modaxo.com" }
      user_type         { :judge }
      team              { nil }
    end

    factory :admin do
      sequence(:name)   { |n| "Admin #{n}" }
      sequence(:email)  { |n| "admin#{n}@modaxo.com" }
      user_type         { :admin }
      team              { nil }
    end
  end
end
