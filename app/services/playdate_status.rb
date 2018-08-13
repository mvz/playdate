# frozen_string_literal: true

class PlaydateStatus
  def self.calculate(playdates, players)
    new(playdates, players).statistics
  end

  attr_reader :playdates, :players

  def initialize(playdates, players)
    @playdates = playdates
    @players = players
  end

  def statistics
    stats = playdates.each_with_object({}) do |pd, h|
      stat = Hash.new(0)
      players.each do |p|
        av = p.current_or_default_availability_for_playdate(pd)
        s = av.status
        stat[s] += 1
      end
      h[pd] = status_count_to_hash stat
    end

    max = stats.map { |_d, s| s[:yes] }.max
    max_has_house = !stats.find { |_d, s|
      s[:yes] == max && s[:house] > 0
    }.nil?

    stats.each_value do |s|
      s[:code] = status_code(s, max, max_has_house, numplayers)
    end
  end

  private

  def status_count_to_hash(stat)
    yes = stat[Availability::STATUS_JA] + stat[Availability::STATUS_HUIS]
    no = stat[Availability::STATUS_NEE]
    maybe = stat[Availability::STATUS_MISSCHIEN]
    house = stat[Availability::STATUS_HUIS]
    { yes: yes, no: no, maybe: maybe, house: house }
  end

  def status_code(status, max, max_has_house, numplayers)
    min = minimum_players_needed
    if max >= min && status[:yes] == max
      return 3 unless max_has_house
      return 3 if status[:house] > 0
      return 2
    end
    return 2 if status[:yes] >= min
    return 0 if status[:no] > (numplayers - min)
    1
  end

  def minimum_players_needed
    [numplayers, MainController::MIN_PLAYERS].min
  end

  def numplayers
    players.length
  end
end
