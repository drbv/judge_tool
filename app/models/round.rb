class Round < ActiveRecord::Base
  belongs_to :round_type
  belongs_to :dance_class
  has_many :dance_rounds
  after_create :set_random_judges

  def self.judge_role_for(index)
    case index
      when 0
        :observer
      when index <= (User.count - 1) / 2
        :acrobatics_judge
      else
        :dance_judge
    end
  end

  def started?
    started
  end

  def set_random_judges
    User.with_role(:judge).order(:rand).each_with_index do |user, index|
      user.add_role Round.judge_role_for(index), self
    end if dance_class
  end
end
