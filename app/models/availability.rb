# frozen_string_literal: true

class Availability < ApplicationRecord
  belongs_to :player
  belongs_to :playdate

  validates :player, :playdate, presence: true
  validates :playdate_id, uniqueness: { scope: [:player_id] }
  validates_associated :player, :playdate
  validates :status, inclusion: { in: 0..3 }

  STATUS_MISSCHIEN = 0
  STATUS_JA = 1
  STATUS_NEE = 2
  STATUS_HUIS = 3

  # TODO: Encapsulate these into methods
  VALUES = [STATUS_MISSCHIEN, STATUS_NEE, STATUS_JA, STATUS_HUIS].freeze
  LONG_DISPLAY = {
    STATUS_MISSCHIEN => "Misschien",
    STATUS_JA        => "Ja",
    STATUS_NEE       => "Nee",
    STATUS_HUIS      => "Huis"
  }.freeze
  SHORT_DISPLAY = {
    STATUS_MISSCHIEN => "?",
    STATUS_JA        => "+",
    STATUS_NEE       => "−",
    STATUS_HUIS      => "h"
  }.freeze
  def status_character
    # TODO: Deprecate?
    SHORT_DISPLAY[status]
  end
end
