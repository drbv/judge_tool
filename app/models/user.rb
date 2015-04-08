class User < ActiveRecord::Base
  rolify
  belongs_to :club
  has_many :dance_ratings
  has_many :acrobatic_ratings
  before_create :generate_credentials
  validates :login, :pin, presence: true

  private

  def generate_credentials
    50.times do |k|
      break if !User.find_by(login: "#{first_name[0].downcase}.#{last_name.downcase}#{k if k>0}") && self.login="#{first_name[0].downcase}.#{last_name.downcase}#{k if k>0}"
    end unless login
    self.pin = SecureRandom.random_number(10000).to_s.rjust(4, '0')
  end
end
