FactoryGirl.define do
  factory :iterated_function_system do
    name  {Faker::Name.name}
    base_shape 0
    parent nil
    association :user, factory: :user
    transforms "[{\"width\":200,\"height\":200,\"left\":100,\"top\":100,\"originX\":\"center\",\"originY\":\"center\"},{\"width\":200,\"height\":200,\"left\":300,\"top\":300,\"originX\":\"center\",\"originY\":\"center\"},{\"width\":200,\"height\":200,\"left\":100,\"top\":300,\"originX\":\"center\",\"originY\":\"center\"}]"

    factory :ifs do
    end
    after(:create) do |f|
      IteratedFunctionSystem.where(id: f.id).update_all(image: "image")
    end
  end
end

