class UserPolicy < ApplicationPolicy

  def index?
    user && user.has_role?(:tournament)
  end

  def show?
    user && user.has_role?(:tournament)
  end

  def create?
    user && user.has_role?(:tournament) && User.count <= 1
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
