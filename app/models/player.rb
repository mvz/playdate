# frozen_string_literal: true

require "digest/sha2"

class Player < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable
  has_many :availabilities, dependent: :destroy
  has_many :playdates, through: :availabilities, inverse_of: :players

  attribute :is_admin, default: false
  validates :is_admin, inclusion: [false, true]

  validates :name, presence: true
  validates :name, length: { minimum: 1 }
  # validates :password, confirmation: true
  validates :name, uniqueness: true

  default_scope { order(:abbreviation) }

  def availability_for_playdate(playdate)
    all_availabilities.find { _1.playdate_id == playdate.id }
  end

  def current_or_default_availability_for_playdate(playdate)
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
