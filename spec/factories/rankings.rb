FactoryBot.define do
  factory :ranking do
    user
    team
    position { 1 }
    category { :technical }
    
    trait :technical do
      category { :technical }
    end
    
    trait :commercial do
      category { :commercial }
    end
    
    trait :overall do
      category { :overall }
    end
    
    factory :technical_ranking do
      category { :technical }
    end
    
    factory :commercial_ranking do
      category { :commercial }
    end
    
    factory :overall_ranking do
      category { :overall }
    end
  end
end
