# frozen_string_literal: true

require 'digest/sha2'

class Player < ApplicationRecord
  has_many :availabilities, dependent: :destroy
  has_many :playdates, through: :availabilities, inverse_of: :players

  validates :name, presence: true
  validates :name, length: { minimum: 1 }
  validates :password, confirmation: true
  validates :name, uniqueness: true
  validates :password, length: { minimum: 5,
                                 if: proc { |user|
                                       user.password_hash.nil? or !user.password.to_s.empty?
                                     } }

  SALT = 'change this to your own salt'

  default_scope { order('abbreviation') }

  attr_reader :password

  def password=(pass)
    @password = pass
    return if pass.blank?
    self.password_hash = hash_password(pass, SALT)
    self.password_salt = SALT
  end

  def self.authenticate(name, pass)
    u = find_by(name: name)
    u.nil? and return nil
    u.check_password(pass) or return nil
    u
  end

  def check_password(pass)
    password_hash == hash_password(pass, password_salt) or return nil
  end

  def availabilities_by_day
    # TODO: Deprecated?
    availabilities.
      includes(:playdate).
      each_with_object({}) { |av, h| h[av.playdate.day] = av }
  end

  def availability_for_playdate(playdate)
    all_availabilities.find { |it| it.playdate_id == playdate.id }
  end

  def current_or_new_availability_for_playdate(playdate)
    availability_for_playdate(playdate) ||
      default_availability_for_playdate(playdate)
  end

  def default_availability_for_playdate(playdate)
    availabilities.build.tap do |av|
      av.playdate = playdate
      av.status = default_status || Availability::STATUS_MISSCHIEN
    end
  end

  private

  def all_availabilities
    @all_availabilities = availabilities
  end

  def hash_password(pass, salt)
    Digest::SHA256.hexdigest(pass + salt)
  end
end
