FactoryBot.define do
  factory :user do
    factory :team_member do
      name { "Team Member" }
      email { "team.member@example.com" }
      password { "password" }
      password_confirmation { "password" }
      user_type { :team_member }
      team
    end

    factory :judge do
      name { "Judge" }
      email { "judge@example.com" }
      password { "password" }
      password_confirmation { "password" }
      user_type { :judge }
      team { nil }
    end

    factory :admin do
      name { "Admin" }
      email { "admin@example.com" }
      password { "password" }
      password_confirmation { "password" }
      user_type { :admin }
      team { nil }
    end
  end
end
