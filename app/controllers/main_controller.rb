# frozen_string_literal: true

class MainController < ApplicationController
  before_action :authorize, except: :feed

  MIN_PLAYERS = 4

  def index
    set_overview_fields
  end

  def edit
    @playdates = relevant_playdates
  end

  def update
    params[:availability].each do |p_id, av_param|
      d = Playdate.find(p_id) or next
      av = @current_user.availability_for_playdate(d)
      av.status = av_param[:status]
      av.save!
    end
    flash[:notice] = 'Wijzigingen opgeslagen.'
    redirect_to action: 'index'
  end

  def feed
    set_overview_fields

    @feed_title = 'Playdate! The Application'
    headers['Content-Type'] = 'application/atom+xml; charset=utf-8'
    @link = url_for action: 'index'

    @updated_at = @playdates.map { |d|
      d.availabilities.map(&:updated_at)
    }.flatten.reject(&:nil?).max

    @content = render_to_string 'feed_table', layout: false, formats: 'html'
    render layout: false, formats: 'xml'
  end

  private

  def relevant_playdates
    Playdate.relevant
  end

  def set_overview_fields
    @players = Player.all
    @playdates = relevant_playdates
    @stats = statistics(@playdates, @players)
    @max = @stats.map { |_d, s| s[:yes] }.max
  end

  def statistics(dates, players)
    stats = dates.each_with_object({}) do |pd, h|
      stat = Hash.new(0)
      players.each do |p|
        av = p.availability_for_playdate(pd)
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
