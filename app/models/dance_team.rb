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

  def get_final_result(round_type)
    round_ids = Round.where(round_type_id: round_type.id).pluck(:id)
    dance_round_ids = DanceRound.where(round_id:round_ids).pluck(:id)
    dance_round_mappings.where(dance_round_id: dance_round_ids).pluck(:result).sum
  end

end
