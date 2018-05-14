class ServiceOfferingsController < ApplicationController
  include ActionController::Helpers
  helper ServiceOfferingsHelper

  before_action :set_service_offering, only: [:show, :update, :destroy]
  wrap_parameters :service_offering, include: ["public_field","non_public_field"]
  before_action :authenticate_user!, only: [:index,:show,:create, :update, :destroy]
  after_action :verify_authorized
  # after_action :verify_policy_scoped, only: [:index]

  def index
    authorize ServiceOffering
    @service_offerings = ServiceOffering.all
    @current_user = current_user
  end

  def show
    authorize @service_offering

    @current_user = current_user
    #now just need to edit the show view to show only non-public stuff if member or organizor. 
  end

  def create

    #need to get the thing_id into the @service_offering, before we can check the authourizatoin
    thing_id = params[:thing_id]
    @service_offering = ServiceOffering.new(service_offering_params)
    @service_offering.thing_id = thing_id

    # puts @service_offering

    authorize @service_offering

    User.transaction do
      if @service_offering.save
        # role=current_user.add_role(Role::ORGANIZER, @service_offering)
        # @service_offering.user_roles << role.role_name
        # role.save!
        render :show, status: :created, location: @service_offering
      else
        render json: {errors:@service_offering.errors.messages}, status: :unprocessable_entity
      end
    end
  end

  def update
    authorize @service_offering

    if @service_offering.update(service_offering_params)
      head :no_content
    else
      render json: {errors:@service_offering.errors.messages}, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @service_offering
    @service_offering.destroy

    head :no_content
  end

  private

    def set_service_offering
      @service_offering = ServiceOffering.find(params[:id])
    end

    def service_offering_params
      params.require(:service_offering).permit(:public_field,:non_public_field)
    end

end
