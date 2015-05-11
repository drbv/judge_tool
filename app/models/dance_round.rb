class DanceRound < ActiveRecord::Base
  belongs_to :round
  has_many :dance_round_mappings
  has_many :dance_teams, :through => :dance_round_mappings
  has_many :acrobatics
  has_many :acrobatic_ratings, through: :acrobatics do
    def observer(observer, dance_round)
      where('acrobatic_ratings.dance_team_id = ?', observer.dance_teams(dance_round).map(&:id))
    end
  end
  has_many :dance_ratings do
    def rating_detail(team, attr)
      where(dance_team_id: team.id).pluck(attr).compact
    end

    def validating(observer, judge, dance_round)
      where(user_id: judge.id, dance_team_id: observer.dance_teams(dance_round).map(&:id))
    end

    def observer(observer, dance_round)
      where(dance_team_id: observer.dance_teams(dance_round).map(&:id))
    end
  end

  def self.next
    where(started: false, finished: false).order(:position).first
  end

  def self.active
    find_by(started: true, finished: false)
  end

  def accepted_by?(user)
    dance_ratings.where(user_id: user.id).all?(&:final?)
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

  def mistakes_adjusting?(dance_team)
    acrobatics.any? { |r| r.mistakes_adjusting?(dance_team) } || adjusting_dance_mistakes?(dance_team)
  end

  def adjusting_dance_mistakes?(dance_team)
    dance_ratings.where(dance_team_id: dance_team.id).map(&:mistakes).uniq.size > 1
  end

  def majority_mistakes(dance_team, observer)
    decider_rating = decider_rating?(observer) ? observer_ratings(observer, dance_team).first.mistakes : nil
    Calculator::MistakeAverage.new(dance_ratings.rating_detail(dance_team, :mistakes), decider_rating).calculate
  end

  def judges
    round.judges
  end

  def observer
    round.observer
  end

  def observers
    round.observers
  end

  def dance_judges
    round.dance_judges
  end

  def acrobatics_judges
    round.acrobatics_judges
  end

  def ready?(observer)
    return @ready unless @ready.nil?
    @ready = !judges.any? { |judge| !judge.rated?(self) } && !dance_ratings.observer(observer, self).any? { |dance_rating| dance_rating.reopened? } && !acrobatic_ratings.observer(observer, self).any? { |dance_rating| dance_rating.reopened? }
  end

  def dance_ratings_average(attr, team)
    @averages ||= {}
    @averages[attr] ||= dance_ratings.where(dance_team_id: team.id, user_id: dance_judges.map(&:id)).pluck(attr).tap do |rating_values|
      rating_values.inject{ |sum, el| sum + el }.to_f / rating_values.size
    end
  end

  def points_per_judge(team)
    points = { 'Akrobatiken' => [], 'Beintechnik' => [] }
    round.dance_judges.each do |judge|
      points['Beintechnik'] << dance_ratings.where(dance_team_id: team.id, user_id: judge.id).first.points.round(2)
    end
    round.acrobatics_judges.each do |judge|
      points['Akrobatiken'] << acrobatic_ratings.where(team_id: team.id, user_id: judge.id).map(&:points).sum
    end
    points.delete 'Akrobatiken' if points['Akrobatiken'].empty?
    points.delete 'Beintechnik' if points['Beintechnik'].empty?
    points
  end

  def points_from_judge(judge, team)
    if judge.has_role?(:dance_judge, round)
      dance_ratings.where(dance_team_id: team.id, user_id: judge.id).first.points.round(2)
    else
      acrobatic_ratings.where(team_id: team.id, user_id: judge.id).map(&:points).sum
    end
  end

  private

  def decider_rating?(observer)
    @decider_rating ||= {}
    return @decider_rating unless @decider_rating[observer.id].nil?
    @decider_rating[observer.id] = dance_ratings.where(user_id: observer.id).count == 1
  end

  def observer_ratings(observer, dance_team)
    dance_ratings.where(user_id: observer.id, dance_team_id: dance_team.id)
  end

end
