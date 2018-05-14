require 'rails_helper'

RSpec.describe "ServiceOfferings", type: :request do
  include_context "db_cleanup_each"
  #originator becomes organizer after creation
  let(:originator) { apply_originator(signup(FactoryGirl.attributes_for(:user)), Thing) }

  context "quick API check" do
    let!(:user) { login originator }

    it_should_behave_like "resource index", :thing
    it_should_behave_like "show resource", :thing
    it_should_behave_like "create resource", :thing
    it_should_behave_like "modifiable resource", :thing
  end

  shared_examples "cannot create" do |status|
    it "fails to create with #{status}" do
      jpost service_offerings_path, service_offering_props
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot update" do |status|
    it "fails to update with #{status}" do
      jput service_offering_path(service_offering_id), service_offering_props
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot delete" do |status|
    it "fails to delete with #{status}" do
      jdelete service_offering_path(service_offering_id)
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end

  shared_examples "can create" do |user_roles=[Role::ORGANIZER]|
    it "creates and has user_roles #{user_roles}" do
      jpost service_offerings_path, service_offering_props
      expect(response).to have_http_status(:created)
      #pp parsed_body
      payload=parsed_body
      expect(payload).to include("id")
      expect(payload).to include("thing_id"=>service_offering.thing_id)
      expect(payload).to include("public_field"=>service_offering.public_field)
      expect(payload).to include("non_public_field"=>service_offering.non_public_field)
    end
    # it "reports error for invalid data" do
    #   jpost service_offerings_path, service_offering_props.except(:name)
    #   #pp parsed_body
    #   #must require :name property -- otherwise get :unprocessable_entity
    #   #must rescue ActionController::ParameterMissing exception
    #   #must render :bad_request
    #   expect(response).to have_http_status(:bad_request)
    # end
  end
  shared_examples "can update" do
    it "updates instance" do
      jput service_offering_path(service_offering_id), service_offering_props
      expect(response).to have_http_status(:no_content)
    end
    # it "reports update error for invalid data" do
    #   jput service_offering_path(service_offering_id), service_offering_props.merge(:name=>nil)
    #   expect(response).to have_http_status(:bad_request)
    # end
  end
  shared_examples "can delete" do
    it "deletes instance" do
      jdelete service_offering_path(service_offering_id)
      expect(response).to have_http_status(:no_content)
    end
  end

  shared_examples "field(s) not redacted" do
    it "list does not show non-members" do
      jget service_offerings_path
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload.size).to eq(3)
    end
  end

  shared_examples "index locked down" do
    it "list is forbidden for unathoirzed" do
      jget service_offerings_path
      expect(response).to have_http_status(:unauthorized)
    end
  end

  shared_examples "can see non public fields" do
    it "list shows non public attributes" do
      jget service_offering_path(service_offering_id)
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload).to include("id"=>service_offering.id)
      expect(payload).to include("thing_id"=>service_offering.thing_id)
      expect(payload).to include("public_field"=>service_offering.public_field)
      expect(payload).to include("non_public_field"=>service_offering.non_public_field)
    end
  end

  shared_examples "cannot see non public fields" do
    it "list shows non public attributes" do
      jget service_offering_path(service_offering_id)
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload).to include("id"=>service_offering.id)
      expect(payload).to include("thing_id"=>service_offering.thing_id)
      expect(payload).to include("public_field"=>service_offering.public_field)
      expect(payload).to_not include("non_public_field"=>service_offering.non_public_field)
      # expect(payload)

    end
  end

  describe "Service Offering authorization" do
    let(:account)  { signup FactoryGirl.attributes_for(:user) }
    let(:thing) {FactoryGirl.create(:thing, :with_roles) }
    let(:service_offering_props)   { FactoryGirl.attributes_for(:service_offering, :thing_id=> thing.id) }
    let(:service_offering_resources) { 3.times.map { create_resource_merge service_offerings_path, :service_offering, {:thing_id=> thing.id} } }
    let(:service_offering_id)   { service_offering_resources[0]["id"] }
    let(:service_offering)      { ServiceOffering.find(service_offering_id) }
    before(:each) do
      login originator
      service_offering_resources
    end

    context "caller is anonymous" do
      before(:each) do 
        logout
      end
      it_should_behave_like "cannot create", :unauthorized
      it_should_behave_like "cannot update", :unauthorized
      it_should_behave_like "cannot delete", :unauthorized
      it_should_behave_like "index locked down"
    end
    context "caller is authenticated no role" do
      before(:each) do 
        login account
      end
      it_should_behave_like "cannot create", :forbidden
      it_should_behave_like "cannot update", :forbidden
      it_should_behave_like "cannot delete", :forbidden
      it_should_behave_like "cannot see non public fields"
      it_should_behave_like "field(s) not redacted" 
    end

    context "caller is member" do
      before(:each) do 
        # thing_resources.each {|t| apply_member(account,Thing.find(t["id"])) }
        apply_member(account,thing)
        login account
      end
      it_should_behave_like "cannot create", :forbidden
      it_should_behave_like "cannot update", :forbidden
      it_should_behave_like "cannot delete", :forbidden
      it_should_behave_like "can see non public fields"
      it_should_behave_like "field(s) not redacted" 
    end

    context "caller is organizer" do
      before(:each) do 
        apply_organizer(account,thing)
        login account
      end
      it_should_behave_like "can create", [Role::ORGANIZER]
      it_should_behave_like "can update"
      it_should_behave_like "can delete"
      it_should_behave_like "can see non public fields"
      it_should_behave_like "field(s) not redacted" 
    end

    context "caller is originator" do
      it_should_behave_like "can create", [Role::ORGANIZER] #originator becomes orginizer
    end
    context "caller is admin" do
      before(:each) do 
        apply_admin(account)
        login account
      end
      it_should_behave_like "cannot create", :forbidden
      it_should_behave_like "cannot update", :forbidden
      it_should_behave_like "can delete", []
    end
  end

end