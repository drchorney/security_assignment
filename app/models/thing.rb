class Thing < ActiveRecord::Base
  include Protectable
  validates :name, :presence=>true

  has_many :thing_images, inverse_of: :thing, dependent: :destroy
  has_many :service_offerings, inverse_of: :thing, dependent: :destroy

  scope :not_linked, ->(image) { where.not(:id=>ThingImage.select(:thing_id)
                                                          .where(:image=>image)) }
                                                        
  # scope :not_linked_so, ->(service_offering) { where.not(:id=>ThingServiceOffering.select(:thing_id)
  #                                                         .where(:service_offering=>service_offering)) }
end
