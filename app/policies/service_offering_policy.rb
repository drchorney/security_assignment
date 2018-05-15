class ServiceOfferingPolicy < ApplicationPolicy
  
  def thing_organizer?

    thing_id = @record.thing_id
    thing = Thing.find_by(:id => thing_id)
    @user.has_role([Role::ORGANIZER], thing.model_name.name, thing.id)
  end

  def thing_organizer_or_admin?
    thing_id = @record.thing_id
    thing = Thing.find_by(:id => thing_id)
    @user.has_role([Role::ORGANIZER,Role::ADMIN], thing.model_name.name, thing.id)
  end
  
  def index?
    true
  end
  def show?
    true
  end

  def create?
    thing_organizer?
  end

  def update?
    thing_organizer?
  end

  def destroy?
    thing_organizer_or_admin?
  end

  def get_things?
    true
  end

  class Scope < Scope
    def user_roles
      joins_clause=["left join Roles r on r.mname='ServiceOffering'",
                    "r.mid=service_offerings.id",
                    "r.user_id #{user_criteria}"].join(" and ")
      scope.select("service_offerings.*, r.role_name")
           .joins(joins_clause)
    end

    def resolve
      user_roles
    end
  end
end
