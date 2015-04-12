class RoundPolicy < ApplicationPolicy

  def admin_index?
    user && user.has_role?(:admin)
  end

  def create?
    user && user.has_role?(:admin)
  end

  def update?
    user && user.has_role?(:admin) && !record.started?
  end

  def destroy?
    user && user.has_role?(:admin) && !record.started?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
