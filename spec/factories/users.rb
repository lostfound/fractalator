FactoryGirl.define do
  factory :user do
    name  { Faker::Name.name }
    email {Faker::Internet.email}
    password "123456781"
    password_confirmation "123456781"
    #confirmed_at nil
    factory :confirmed_user do
      after(:create) do |u|
        u.confirm!
      end
    end
  end
end
