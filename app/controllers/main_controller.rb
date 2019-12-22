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
      av = current_user.current_or_default_availability_for_playdate(d)
      av.status = av_param[:status]
      av.save!
    end
    flash[:notice] = "Wijzigingen opgeslagen."
    redirect_to action: "index"
  end

  def feed
    set_overview_fields

    @feed_title = "Playdate! The Application"
    headers["Content-Type"] = "application/atom+xml; charset=utf-8"
    @link = url_for action: "index"

    playdate_ids = @playdates.map(&:id)

    @updated_at = @players
      .flat_map(&:availabilities)
      .select { |it| playdate_ids.include? it.playdate_id }
      .map(&:updated_at).compact.max

    @content = render_to_string "feed_table", layout: false, formats: [:html]
    render layout: false
  end

  private

  def relevant_playdates
    Playdate.relevant
  end

  def set_overview_fields
    @players = Player.all.includes(:availabilities)
    @playdates = relevant_playdates
    @stats = PlaydateStatus.calculate(@playdates, @players)
    @max = @stats.map { |_d, s| s[:yes] }.max
  end
end
