FactoryBot.define do
  factory :exclusion do
    association :team
    association :excluded_team, factory: :team
  end
end