class RoundPolicy < ApplicationPolicy

  def admin_index?
    user && user.has_role?(:admin)
  end

  def show?
    user && user.has_role?(:admin) && !record.round_type.no_dance
  end

  def create?
    user && user.has_role?(:admin)
  end

  def update?
    user && user.has_role?(:admin) && !record.started? && !record.round_type.no_dance
  end

  def destroy?
    user && user.has_role?(:admin) && !record.started?
  end

  def start?
    user && user.has_role?(:admin) && !record.started? && Round.where('position < ?', record.position).all?(&:closed?)
  end

  def close?
    user && user.has_role?(:admin) && record.active? && (record.round_type.no_dance || record.judges.count <=0 || (DanceRound.next.nil? && record.dance_rounds.all?(&:closed?)))
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
