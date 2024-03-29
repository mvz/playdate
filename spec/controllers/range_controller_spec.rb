# frozen_string_literal: true

require "rails_helper"

RSpec.describe RangeController, type: :controller do
  fixtures :players

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

  describe "#create" do
    it "redirects to the main controller" do
      post :create, params: {}, session: playersession
      expect(response).to redirect_to controller: "main", action: "index"
    end

    it "fills up to the end of the current month if more than one week is left" do
      Timecop.travel Date.new(2022, 10, 16) do
        expect { post :create, params: {}, session: playersession }
          .to change(Playdate, :count).by 4
        startdate = Time.zone.today + 1
        enddate = startdate.end_of_month
        startdate.upto(enddate) do |day|
          if MainHelper::CANDIDATE_WEEKDAYS.include?(day.wday)
            expect(Playdate.find_by(day: day)).not_to be_nil
          else
            expect(Playdate.find_by(day: day)).to be_nil
          end
        end
      end
    end

    it "fills up to the end of next month if current month is already filled" do
      Timecop.travel Date.new(2022, 10, 16) do
        Playdate.make_new_range(1, PlaydatesController::DAY_SATURDAY)
        expect { post :create, params: {}, session: playersession }
          .to change(Playdate, :count).by 10
        startdate = Time.zone.today + 1
        enddate = startdate.next_month.end_of_month
        startdate.upto(enddate) do |day|
          if MainHelper::CANDIDATE_WEEKDAYS.include?(day.wday)
            expect(Playdate.find_by(day: day)).not_to be_nil
          else
            expect(Playdate.find_by(day: day)).to be_nil
          end
        end
      end
    end

    it "fills up to the end of next month if less than one week is left" do
      Timecop.travel Date.new(2022, 10, 25) do
        expect { post :create, params: {}, session: playersession }
          .to change(Playdate, :count).by 10
        startdate = Time.zone.today + 1
        enddate = startdate.next_month.end_of_month
        startdate.upto(enddate) do |day|
          if MainHelper::CANDIDATE_WEEKDAYS.include?(day.wday)
            expect(Playdate.find_by(day: day)).not_to be_nil
          else
            expect(Playdate.find_by(day: day)).to be_nil
          end
        end
      end
    end
  end

  private

  def playersession
    {user_id: players(:matijs).id}
  end
end
