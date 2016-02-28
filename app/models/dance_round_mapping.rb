class DanceRoundMapping < ActiveRecord::Base
  belongs_to :dance_round
  belongs_to :dance_team
  belongs_to :repeated_mapping, class_name: 'DanceRoundMapping'
  belongs_to :user

  def dance_ratings
    DanceRating.where(dance_round_id: dance_round_id, dance_team_id: dance_team_id)
  end

  def repeat!
    update_attributes repeated: true, repeated_mapping_id: new_mapping.id
  end

  def new_mapping
    @last_dance_round = dance_round.round.dance_rounds.order(:position).last
    if @last_dance_round.dance_teams.count >= dance_round.round.max_teams || @last_dance_round.closed?
      @last_dance_round = dance_round.round.dance_rounds.create position: (@last_dance_round.position + 1)
    end
    @last_dance_round.dance_round_mappings.create dance_team: dance_team, repeating: true
  end
end