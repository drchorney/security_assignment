FactoryGirl.define do
  factory :service_offering do
    public_field "MyString"
    non_public_field "MyString"
  end
end
