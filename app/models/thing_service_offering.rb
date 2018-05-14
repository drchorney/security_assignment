class ThingServiceOffering < ActiveRecord::Base
  belongs_to :service_offering
  belongs_to :thing

  validates :service_offering, :thing, presence: true

  scope :with_name,    ->{ joins(:thing).select("thing_images.*, things.name as thing_name")}
  scope :with_public, ->{ joins(:service_offering).select("thing_service_offerings.*, service_offerings.public_field as service_offering_public_field")}

end
