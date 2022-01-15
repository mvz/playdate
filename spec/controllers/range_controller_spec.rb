# frozen_string_literal: true

require "rails_helper"

RSpec.describe RangeController, type: :controller do
  fixtures :players, :playdates, :availabilities

  render_views

  it "authorization" do
    get :new, params: {}, session: {}
    assert_redirected_to controller: "session", action: "new"
    post :create, params: {}, session: {}
    assert_redirected_to controller: "session", action: "new"
  end

  it "new" do
    oldcount = Playdate.count
    get :new, params: {}, session: playersession
    assert_response :success
    assert_template "new"
    assert_select "form"
    assert_equal Playdate.count, oldcount
    assert_select "h1", "Speeldagen toevoegen"
  end

  # FIXME: Use fixed dates rather than relying on logic based on the current
  # date. Test each case (only this month, also next month) separately, with
  # seperate checks for the borderline dates.
  it "create" do
    oldcount = Playdate.count
    post :create, params: {}, session: playersession
    assert_response :redirect
    assert_redirected_to controller: "main", action: "index"
    assert_operator Playdate.count, :>, oldcount + 1
    assert_operator Playdate.count, :<=, oldcount + 12
    startdate = Time.zone.today + 1
    enddate =
      if startdate + 7 <= Time.zone.today.end_of_month
        Time.zone.today.end_of_month
      else
        Time.zone.today.next_month.end_of_month
      end
    (startdate + 1).upto(enddate) do |day|
      if MainHelper::CANDIDATE_WEEKDAYS.include?(day.wday)
        refute_nil Playdate.find_by(day: day)
      else
        assert_nil Playdate.find_by(day: day)
      end
    end
  end

  private

  def playersession
    {user_id: players(:matijs).id}
  end
end
