require 'ajax_scaffold'

class Player < ActiveRecord::Base
  SALT = 'change this to your own salt'
  def password=(pass)
    self.password_hash = Digest::SHA256.hexdigest(pass + SALT)
  end
end
