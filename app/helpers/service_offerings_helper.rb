module ServiceOfferingsHelper
  def restrict_non_public_field? service_offering, user
    blah = !user.has_role(["member","organizer","admin"],service_offering.thing.model_name.to_s,service_offering.thing_id)
  end
end 
