class Availability < ActiveRecord::Base
  belongs_to :player
  belongs_to :playdate
  validates_presence_of :player, :playdate
  validates_uniqueness_of :playdate_id, :scope => [:player_id]
  validates_associated :player, :playdate
  validates_inclusion_of :status, :in => 0..3

  STATUS_MISSCHIEN = 0
  STATUS_JA = 1
  STATUS_NEE = 2
  STATUS_HUIS = 3

  # TODO: Encapsulate these into methods
  VALUES = [ STATUS_MISSCHIEN, STATUS_NEE, STATUS_JA, STATUS_HUIS ]
  LONG_DISPLAY = {
    STATUS_MISSCHIEN  => "Misschien",
    STATUS_JA         => "Ja",
    STATUS_NEE        => "Nee",
    STATUS_HUIS       => "Huis"
  }
  SHORT_DISPLAY = {
    STATUS_MISSCHIEN  => "?",
    STATUS_JA         => "+",
    STATUS_NEE        => "&minus;",
    STATUS_HUIS       => "h"
  }
  def status_character
    # TODO: Deprecate?
    SHORT_DISPLAY[self.status]
  end
end
