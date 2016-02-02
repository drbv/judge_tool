class DanceRoundRating < ActiveRecord::Base
  belongs_to :dance_team
  belongs_to :dance_round
  belongs_to :user

  def find_or_create(dance_round, dance_team, user)
    find_by(:dance_round_id => dance_round.id, :dance_team_id => dance_team.id, :user_id => user.id) ||
      create(mistakes: '', dance_team_id: dance_team.id, dance_round_id: dance_round.id, user_id: user.id)
  end

end
