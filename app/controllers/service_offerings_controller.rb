class ServiceOfferingsController < ApplicationController

  before_action :set_service_offering, only: [:show, :update, :destroy]
  wrap_parameters :service_offering, include: ["public_field","non_public_field"]
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: [:index]

  def index
    authorize ServiceOffering
    @service_offerings = policy_scope(ServiceOffering.all)
    @service_offerings = ServiceOfferingPolicy.merge(@service_offerings)
  end

  def show
    authorize @service_offering
    service_offerings = policy_scope(ServiceOffering.where(:id=>@service_offering.id))
    @service_offering = ServiceOfferingPolicy.merge(service_offerings).first
  end

  def create
    authorize ServiceOffering
    @service_offering = ServiceOffering.new(service_offering_params)
    @service_offering.creator_id=current_user.id

    User.transaction do
      if @service_offering.save
        role=current_user.add_role(Role::ORGANIZER, @service_offering)
        @service_offering.user_roles << role.role_name
        role.save!
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
