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

  def get_final_result(round)
    @final_results ||= {}
    @final_results[round.id] ||= calculate_final_result(round)
  end

  def tso_malus?(round)
    tso_dance_round_id = dance_rounds.where(round_id: round.id).order(:position).last
    drating = dance_round_ratings.where(dance_round_id: tso_dance_round_id).first
    if drating && drating.result > 0
      true
    else
      false
    end
  end

  def has_danced?(round)

    if dance_ratings
      dance_ratings.where(dance_round_id: round.dance_rounds.pluck(:id)).pluck(:final).size > 0
    else
      false
    end

  end

  private

  def calculate_final_result(round)
    final_result = dance_round_mappings.where(dance_round_id: round.dance_rounds.pluck(:id),dance_team: id,repeated: false).first.result

    if round.round_type.name == "Endrunde Akrobatik"
      connected_round_ids= Round.where(round_type_id: RoundType.find_by_name('Endrunde Fußtechnik').id).pluck(:id)
      dance_round_ids = dance_rounds.where(round_id: connected_round_ids)
      final_result += dance_round_mappings.where(dance_round_id: dance_round_ids,dance_team: self.id,repeated: false).first.result

    #elsif round.round_type.name == "Endrunde Fußtechnik"
    #  connected_round_ids= Round.where(round_type_id: RoundType.find_by_name('Endrunde Akrobatik').id).pluck(:id)
    #  dance_round_ids = dance_rounds.where(round_id: connected_round_ids)
    #  final_result += dance_round_mappings.where(dance_round_id: dance_round_ids,dance_team: self.id,repeated: false).first.result
    end
    final_result.round(2)
  end
end
