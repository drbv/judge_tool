class Round < ActiveRecord::Base
  resourcify
  belongs_to :round_type
  belongs_to :dance_class
  has_many :dance_rounds

  def self.active
    where(started: true, closed: false).first
  end

  def self.judge_role_for(index)
    case index
      when 0
        :observer
      when (1..((User.count - 1) / 2))
        :acrobatics_judge
      else
        :dance_judge
    end
  end
  def has_acrobatics?
    !self.round_type.name.include? 'Fuß'
  end
  def active?
    started? && !closed?
  end

  def started?
    started
  end

  def start!
    self.started = true
    self.start_time = Time.now
    save
  end

  def closed?
    closed
  end

  def close!
    update_attribute :closed, true
    generate_rating_export_file
  end

  def judges
    @judges ||= observers + dance_judges + acrobatics_judges
  end

  def dance_judges
    User.with_role :dance_judge, self
  end

  def acrobatics_judges
    User.with_role :acrobatics_judge, self
  end

  def observer
    User.with_role(:observer, self).first
  end

  def observers
    User.with_role :observer, self
  end

  def generate_rating_export_file
    File.write(Rails.root.join('tmp',"T#{self.tournament_number}_RT#{self.rt_id}.txt"),'')

    dance_rounds.each do |dance_round|
      dance_round.dance_ratings.group_by(&:user).each do |user, dance_ratings|

      end

    end

    #  line = "#{URI.encode_www_form WR_ID: rating.user.id, rt_ID: rating.dance_round.round.position}\n"
    #  File.open(Rails.root.join('tmp','rating_list.csv'), 'a') do |f|
    #    f<<(line)
    #  end
    #end
  end

  # def set_random_judges
  #   User.with_role(:judge).order(ActiveRecord::Base.connection.instance_values["config"][:adapter].start_with?('mysql') ? 'RAND()' : 'RANDOM()').each_with_index do |user, index|
  #     user.add_role Round.judge_role_for(index), self
  #   end if dance_class
  # end

end
