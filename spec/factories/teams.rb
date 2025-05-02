FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    description { "A competitive team for testing" }
  end
end
