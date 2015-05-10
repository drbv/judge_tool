class User < ActiveRecord::Base
  rolify
  belongs_to :club
  has_many :dance_ratings
  has_many :acrobatic_ratings
  before_validation :generate_credentials
  validates :login, :pin, presence: true
  validates :login, uniqueness: true

  def dance_teams(dance_round)
    dance_round.dance_teams.where('dance_round_mappings.user_id = ?', id)
  end

  def has_to_rate?(dance_round)
    !dance_teams(dance_round).empty?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def rated?(dance_round)
    dance_round.dance_ratings.where(user_id: id).exists? || dance_round.acrobatic_ratings.where(user_id: id).exists?
  end

  def open_discussion?(dance_round)
    dance_round.dance_ratings.where('user_id = ? AND reopen > 0', id).exists? || dance_round.acrobatic_ratings.where('user_id = ? AND reopen > 0', id).exists?
  end

  private

  def generate_credentials
    50.times do |k|
      generated_login = "#{first_name[0].downcase}.#{last_name.downcase}#{k if k>0}"
      break if User.find_by(login: generated_login).blank? && self.login = generated_login
    end unless login
    self.pin = SecureRandom.random_number(10000).to_s.rjust(4, '0')
  end
end
