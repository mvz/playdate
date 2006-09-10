class Availability < ActiveRecord::Base
  belongs_to :player
  belongs_to :playdate
  validates_presence_of :player_id, :playdate_id, :status
  validates_uniqueness_of :playdate_id, :scope => [:player_id]

  STATUS_MISSCHIEN = 0
  STATUS_JA = 1
  STATUS_NEE = 2
  STATUS_HUIS = 3
  STATUS_USE_DEFAULT = 100

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
    STATUS_NEE        => "-",
    STATUS_HUIS       => "h"
  }
  def status_character
    if self.status == STATUS_USE_DEFAULT
      case self.player.default_status || STATUS_MISSCHIEN
      when STATUS_MISSCHIEN
        ""
      else
      "(" + SHORT_DISPLAY[self.player.default_status] + ")"
      end
    else
      SHORT_DISPLAY[self.status]
    end
  end
end
