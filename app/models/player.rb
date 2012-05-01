require 'digest/sha2'

class Player < ActiveRecord::Base
  has_many :availabilities
  has_many :playdates, :through => :availabilities

  attr_accessible :name, :password, :password_confirmation

  validates_presence_of :name
  validates_length_of :name, :minimum => 1
  validates_confirmation_of :password
  validates_uniqueness_of :name
  validates_length_of :password, :minimum => 5,
    :if => Proc.new { |user|
         user.password_hash.nil? or user.password.to_s.length > 0
       }

  SALT = 'change this to your own salt'

  default_scope order('abbreviation')

  def password
    @password
  end

  def password=(pass)
    @password = pass
    if pass.nil? or pass == "" then
      return
    end
    self.password_hash = hash_password(pass, SALT)
    self.password_salt = SALT
  end

  def self.authenticate(nm, pass)
    u = self.find_by_name(nm)
    u.nil? and return nil
    u.check_password(pass) or return nil
    return u
  end

  def check_password(pass)
    self.password_hash == hash_password(pass, self.password_salt) or return nil
  end

  def availabilities_by_day
    # TODO: Deprecated?
    self.availabilities.inject({}) { |h,av|
      h[av.playdate.day] = av; h
    }
  end

  def availability_for_playdate(pd)
    availabilities.find_by_playdate_id(pd.id) ||
      default_availability_for_playdate(pd)
  end

  def default_availability_for_playdate(pd)
    availabilities.build.tap do |av|
      av.playdate = pd
      av.status = default_status || Availability::STATUS_MISSCHIEN
    end
  end

  private
  def hash_password(pass, salt)
    return Digest::SHA256.hexdigest(pass + salt)
  end
end
