class ServiceOffering < ActiveRecord::Base
  include Protectable
  has_many :thing_service_offerings, inverse_of: :service_offering, dependent: :destroy
  has_many :things, through: :thing_service_offerings
end
