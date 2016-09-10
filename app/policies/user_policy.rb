class UserPolicy < ApplicationPolicy

  def index?
    user && user.has_role?(:admin)
  end

  def show?
    user && user.has_role?(:admin)
  end

  def create?
    user && user.has_role?(:admin) && User.count <= 2
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
