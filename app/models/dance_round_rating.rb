class DanceRoundRating < ActiveRecord::Base
  belongs_to :dance_team
  belongs_to :dance_round
  belongs_to :user

  def self.get_dance_round_rating(dance_round,dance_team,user)
    DanceRoundRating.where(:dance_round_id => dance_round.id, :dance_team_id => dance_team.id, :user_id => user.id).first
  end
end
