# frozen_string_literal: true

require "rails_helper"

RSpec.describe RangeController, type: :controller do
  fixtures :players, :playdates, :availabilities

  render_views

  it "authorization" do
    get :new, params: {}, session: {}
    expect(response).to redirect_to controller: "session", action: "new"
    post :create, params: {}, session: {}
    expect(response).to redirect_to controller: "session", action: "new"
  end

  it "new" do
    oldcount = Playdate.count
    get :new, params: {}, session: playersession
    expect(response).to be_successful
    expect(response).to render_template "new"
    expect(response.body).to have_css "form"
    expect(oldcount).to eq Playdate.count
    expect(response.body).to have_css "h1", text: "Speeldagen toevoegen"
  end

  # FIXME: Use fixed dates rather than relying on logic based on the current
  # date. Test each case (only this month, also next month) separately, with
  # seperate checks for the borderline dates.
  it "create" do
    oldcount = Playdate.count
    post :create, params: {}, session: playersession
    expect(response).to redirect_to controller: "main", action: "index"
    expect(Playdate.count).to be > oldcount + 1
    expect(Playdate.count).to be <= oldcount + 12
    startdate = Time.zone.today + 1
    enddate =
      if startdate + 7 <= Time.zone.today.end_of_month
        Time.zone.today.end_of_month
      else
        Time.zone.today.next_month.end_of_month
      end
    (startdate + 1).upto(enddate) do |day|
      if MainHelper::CANDIDATE_WEEKDAYS.include?(day.wday)
        expect(Playdate.find_by(day: day)).not_to be_nil
      else
        expect(Playdate.find_by(day: day)).to be_nil
      end
    end
  end

  private

  def playersession
    {user_id: players(:matijs).id}
  end
end
