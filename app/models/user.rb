class User < ActiveRecord::Base
  rolify
  belongs_to :club
  has_many :dance_ratings
  has_many :acrobatic_ratings
  before_validation :generate_credentials
  validates :login, :pin, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def rated?(dance_round)
    dance_round.dance_ratings.where(user_id: id).exists? || dance_round.acrobatic_ratings.where(user_id: id).exists?
  end

  private

  def generate_credentials
    50.times do |k|
      break if !User.find_by(login: "#{first_name[0].downcase}.#{last_name.downcase}#{k if k>0}") && self.login="#{first_name[0].downcase}.#{last_name.downcase}#{k if k>0}"
    end unless login
    self.pin = SecureRandom.random_number(10000).to_s.rjust(4, '0')
  end
end
