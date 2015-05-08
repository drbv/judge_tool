class Acrobatic < ActiveRecord::Base
  belongs_to :dance_team
  belongs_to :dance_round
  belongs_to :acrobatic_type
  has_many :acrobatic_ratings do
    def rating_detail(team)
      where(dance_team_id: team.id).pluck(:rating)
    end

    def validating(observer, judge, dance_round)
      where(user_id: judge.id, dance_team_id: observer.dance_teams(dance_round).map(&:id))
    end
  end

  def mistake_diff_to_big(team)
    ary = acrobatic_ratings.where(dance_team_id: team.id).map(&:punishment)
    ary.max - ary.min > 10
  end

  def diff_to_big(team)
    ary = acrobatic_ratings.rating_detail(team)
    return false if ary.empty?
    ary.max - ary.min > 40
  end
end
