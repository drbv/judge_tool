class Dancer < ActiveRecord::Base
  has_and_belongs_to_many :dance_teams

  def full_name
    "#{first_name} #{last_name}"
  end
end
