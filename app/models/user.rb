class User < ActiveRecord::Base
  rolify
  has_secure_password
end
