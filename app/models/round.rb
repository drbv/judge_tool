class Round < ActiveRecord::Base
  resourcify
  belongs_to :round_type
  belongs_to :dance_class
  has_many :dance_rounds

  def self.active
    where('started AND NOT closed').first
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

  # def set_random_judges
  #   User.with_role(:judge).order(ActiveRecord::Base.connection.instance_values["config"][:adapter].start_with?('mysql') ? 'RAND()' : 'RANDOM()').each_with_index do |user, index|
  #     user.add_role Round.judge_role_for(index), self
  #   end if dance_class
  # end

end
