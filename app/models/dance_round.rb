class DanceRound < ActiveRecord::Base
  belongs_to :round
  has_many :dance_round_mappings
  has_many :dance_teams, :through => :dance_round_mappings
  has_many :acrobatics
  has_many :acrobatic_ratings, through: :acrobatics do
    def observer(observer, dance_round)
      where('acrobatic_ratings.dance_team_id IN (?)', observer.dance_teams(dance_round).map(&:id))
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

  def reopened_for?(user)
    if user.has_role?(:dance_judge, round)
      dance_ratings.where(user_id: user.id).any? { |dance_rating| dance_rating.reopened? }
    elsif user.has_role?(:acrobatics_judge, round)
      acrobatic_ratings.where(user_id: user.id).any? { |acrobatic_rating| acrobatic_rating.reopened? }
    else
      false
    end
  end

  def close!
    self.round.generate_rating_export_file
    update_attributes finished: true, finished_at: Time.now
  end

  def start!
    update_attributes started: true, started_at: Time.now
    observers=round.observers.sort_by{|observer| observer.licence}
    if observers.count == 1
      dance_round_mappings.each {|mapping| mapping.update_attribute :user_id, observers.first.id}
    else
      dance_round_mappings.sort_by{|mapping| mapping.dance_team.startnumber}.each{|mapping| mapping.update_attribute :user_id, observers.pop.id}
    end
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
    dance_ratings.where(dance_team_id: team.id, user_id: dance_judges.map(&:id)).map(&attr).tap do |rating_values|
      @averages[attr] ||= rating_values.inject { |sum, el| sum + el }.to_f / rating_values.size
    end
    @averages[attr]
  end

  def points_per_judge(team)
    points = { 'Akrobatiken' => [], 'Beintechnik' => [] }
    round.dance_judges.each do |judge|
      points['Beintechnik'] << dance_ratings.where(dance_team_id: team.id, user_id: judge.id).first.points.round(2)
    end
    round.acrobatics_judges.each do |judge|
      points['Akrobatiken'] << acrobatic_ratings.where(dance_team_id: team.id, user_id: judge.id).map(&:points).sum
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

  def decider_rating?(observer)
    @decider_rating ||= {}
    return @decider_rating unless @decider_rating[observer.id].nil?
    @decider_rating[observer.id] = dance_ratings.where(user_id: observer.id).count == 1
  end

  def reopened?
    if dance_ratings.blank? && acrobatic_ratings.blank?
      false
    else
      dance_ratings.any?(&:reopened?) || (acrobatic_ratings && acrobatic_ratings.any?(&:reopened?))
    end
  end

  def export_dance_ratings
    dance_round_mappings.where('NOT repeating').map do |mapping|
      if mapping.repeated && mapping.repeated_mapping.dance_round.closed?
        mapping.repeated_mapping
      else
        mapping
      end
    end.flat_map(&:dance_ratings).select { |rating| rating.user.is_judge?(dance_round.round) }
  end

  def export_acrobatic_ratings
    acrobatics.where('NOT repeating').map do |acrobatic|
      if acrobatic.repeated && acrobatic.repeated_acrobatic.dance_round.closed?
        acrobatic.repeated_acrobatic
      else
        acrobatic
      end
    end.flat_map(&:acrobatic_ratings).select { |rating| rating.user.is_judge? dance_round.round }
  end

  def repeated?(team)
    dance_round_mappings.where(dance_team_id: team.id).first.repeated
  end

  def repeating?(team)
    dance_round_mappings.where(dance_team_id: team.id).first.repeating
  end
  private

  def observer_ratings(observer, dance_team)
    dance_ratings.where(user_id: observer.id, dance_team_id: dance_team.id)
  end

end
