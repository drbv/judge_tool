class RoundPolicy < ApplicationPolicy

  def admin_index?
    user && user.has_role?(:admin)
  end

  def create?
    user && user.has_role?(:admin)
  end

  def update?
    user && user.has_role?(:admin) && !record.started? && !record.dance_class.blank?
  end

  def destroy?
    user && user.has_role?(:admin) && !record.started?
  end

  def start?
    user && user.has_role?(:admin) && !record.started? && Round.where('start_time < ?', record.start_time).all?(&:closed?)
  end

  def close?
    user && user.has_role?(:admin) && record.active? && record.dance_class.blank?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
