class BeamerPolicy < ApplicationPolicy

  def index?
    user && ( user.has_role?(:admin) || user.has_role?(:beamer))
  end

  def show?
    user && ( user.has_role?(:admin) || user.has_role?(:beamer))
  end

  def delete?
    user &&  user.has_role?(:admin)
  end

  def create?
    user &&  user.has_role?(:admin)
  end

  def update?
    user && ( user.has_role?(:admin) || user.has_role?(:beamer))
  end

end
