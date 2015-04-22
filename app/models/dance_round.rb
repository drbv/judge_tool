class DanceRound < ActiveRecord::Base
  belongs_to :round
  has_and_belongs_to_many :dance_teams
  has_many :acrobatics
  has_many :acrobatic_ratings, through: :acrobatics
  has_many :dance_ratings do
    def rating_detail(team, attr)
      where(dance_team_id: team.id).pluck(attr).compact
    end

    def from(judge, team)
      find_by(dance_team_id: team.id, user_id: judge.id)
    end
  end

  def self.next
    where(started: false, finished: false).order(:position).first
  end

  def self.active
    find_by(started: true, finished: false)
  end

  def active?
    started && !finished
  end

  def closed?
    finished
  end

  def close!
    update_attributes finished: true, finished_at: Time.now
  end

  def start!
    update_attributes started: true, started_at: Time.now
  end

  def judges
    round.judges
  end

  def observer
    round.observer
  end

  def dance_judges
    round.dance_judges
  end

  def acrobatics_judges
    round.acrobatics_judges
  end

  def ready?
    ! judges.any? {|judge| !judge.rated?(self)} && !dance_ratings.any? {|dance_rating| dance_rating.reopened?} && !acrobatic_ratings.any? {|dance_rating| dance_rating.reopened?}
  end

  def diff_to_big(dance_team, attr)
    if attr == :full_mistakes
      ary = dance_ratings.where(dance_team_id: dance_team.id).map(&:punishment)
      ary.max - ary.min > 10
    else
      ary = dance_ratings.rating_detail(dance_team, attr)
      ary.max - ary.min > 40
    end
  end

  def points_per_judge(team)
    points = { 'Akrobatiken' => [], 'Beintechnik' => [] }
    round.dance_judges.each do |judge|
      points['Beintechnik'] << dance_ratings.from(judge, team).points
    end
    round.acrobatics_judges.each do |judge|
      points['Akrobatiken'] << acrobatic_ratings.where(team_id: team.id, user_id: judge.id).map(&:points).sum
    end
    points.delete 'Akrobatiken' if points['Akrobatiken'].empty?
    points.delete 'Beintechnik' if points['Beintechnik'].empty?
    points
  end

end
