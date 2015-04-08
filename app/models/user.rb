class User < ActiveRecord::Base
  rolify
  has_secure_password
  belongs_to :club
  has_many :dance_ratings
  has_many :acrobatic_ratings
end
