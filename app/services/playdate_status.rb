# frozen_string_literal: true

class PlaydateStatus
  def self.calculate(playdates, players)
    new.statistics(playdates, players)
  end

  def statistics(playdates, players)
    availabilities = Availability.where(playdate_id: playdates, player_id: players)

    stats = playdates.each_with_object({}) do |pd, h|
      date_avs = availabilities.select { |it| it.playdate_id == pd.id }

      stat = Hash.new(0)
      players.each do |p|
        av = date_avs.find { |it| it.player_id == p.id } ||
          p.default_availability_for_playdate(pd)
        s = av.status
        stat[s] += 1
      end
      yes = stat[Availability::STATUS_JA] + stat[Availability::STATUS_HUIS]
      no = stat[Availability::STATUS_NEE]
      maybe = stat[Availability::STATUS_MISSCHIEN]
      house = stat[Availability::STATUS_HUIS]
      h[pd] = { yes: yes, no: no, maybe: maybe, house: house }
    end

    max = stats.map { |_d, s| s[:yes] }.max
    max_has_house = !stats.find { |_d, s|
      s[:yes] == max && s[:house] > 0
    }.nil?
    numplayers = players.length
    min = [numplayers, MainController::MIN_PLAYERS].min

    stats.each_value do |s|
      s[:code] = status_code(s, min, max, max_has_house, numplayers)
    end
  end

  def status_code(status, min, max, max_has_house, numplayers)
    if max >= min && status[:yes] == max
      return 3 unless max_has_house
      return 3 if status[:house] > 0
      return 2
    end
    return 2 if status[:yes] >= min
    return 0 if status[:no] > (numplayers - min)
    1
  end
end
