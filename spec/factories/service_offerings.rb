FactoryGirl.define do
  factory :service_offering do
    public_field Faker::Lorem.paragraph
    non_public_field Faker::Lorem.paragraph

    before(:create) do |service_offering, props|
      service_offering.thing_id = props.thing_id
    end

  end
end
