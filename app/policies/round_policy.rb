class RoundPolicy < ApplicationPolicy

  def admin_index?
    user && user.has_role?(:admin)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
