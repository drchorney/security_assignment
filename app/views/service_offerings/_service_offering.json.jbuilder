json.extract! service_offering, :id, :thing_id, :so_name, :public_field, :created_at, :updated_at 
json.non_public_field service_offering.non_public_field   unless restrict_non_public_field? service_offering, current_user
json.url service_offering_url(service_offering, format: :json)
json.user_roles service_offering.user_roles    unless service_offering.user_roles.empty?
