class DanceTeam < ActiveRecord::Base
  belongs_to :club
  belongs_to :dance_class
  has_and_belongs_to_many :dancers
  has_many :dance_ratings
  has_many :acrobatic_ratings
  has_many :dance_round_mappings
  has_many :dance_rounds, through: :dance_round_mappings
  has_many :acrobatics
  has_many :dance_round_ratings
  default_scope -> { order('startnumber') }

  def full_name
    name ? name : dancers.map(&:full_name).join(' und ')
  end

  def name_with_startnumber
    "#{startnumber} #{full_name}"
  end
end
