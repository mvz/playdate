# frozen_string_literal: true

require "rails_helper"

RSpec.describe MainController, type: :controller do
  fixtures :players, :playdates, :availabilities

  let!(:today) { Playdate.create!(day: Time.zone.today) }
  let!(:tomorrow) { Playdate.create!(day: Time.zone.tomorrow) }

  render_views

  before do
    stub_const("MainController::MIN_PLAYERS", 2)
  end

  it "authorization" do
    [:index, :edit, :update].product([:get, :post]) do |(a, m)|
      method(m).call(a, params: {}, session: {})
      expect(response).to redirect_to controller: "session", action: "new"
    end
  end

  describe "#index" do
    it "index_as_user" do
      get :index, params: {}, session: playersession

      aggregate_failures do
        expect(response).to be_successful
        expect(response).to render_template "index"
        expect(assigns(:playdates)).not_to be_nil
        expect(assigns(:playdates)).to eq [today, tomorrow]
        expect(assigns(:stats)).not_to be_nil
        expect(response.body).to have_button "Meer>>"
        expect(response.body).not_to have_link href: "/playdates"

        expect(response.body).to have_css "h1", text: "Playdate! The Application"
      end
    end

    it "index_as_admin" do
      get :index, params: {}, session: adminsession

      aggregate_failures do
        expect(response).to be_successful
        expect(response).to render_template "index"
        expect(assigns(:playdates)).not_to be_nil
        expect(assigns(:stats)).not_to be_nil
        expect(response.body).to have_link href: "/playdates"
      end
    end

    it "index_all_dates_present" do
      # today and tomorrow are already there
      startdate = Time.zone.today + 2
      enddate = Time.zone.today.next_month.end_of_month
      startdate.upto(enddate) do |day|
        next unless MainHelper::CANDIDATE_WEEKDAYS.include?(day.wday)

        Playdate.new(day:).save!
      end
      get :index, params: {}, session: playersession
      expect(response.body).not_to have_link href: "/more"
    end

    it "index_shows_no_for_bad_day" do
      [:matijs, :robert].each do |p|
        players(p).availabilities.create!(playdate: today,
          status: Availability::STATUS_NEE)
      end

      get :index, params: {}, session: playersession

      expect(response.body).to have_css "tr.summary td:first-of-type", text: "Nee"
    end

    it "index_shows_empty_for_neutral_day" do
      get :index, params: {}, session: playersession

      expect(response.body).to have_css "tr.summary td:first-of-type", text: ""
    end

    it "index_shows_best_for_only_good_day" do
      [:matijs, :robert].each do |p|
        players(p).availabilities.create!(playdate: today,
          status: Availability::STATUS_JA)
      end

      get :index, params: {}, session: playersession

      expect(response.body).to have_css "tr.summary td:first-of-type", text: "Beste"
    end

    it "index_both_days_good_but_first_is_best" do
      [:matijs, :robert].product([today, tomorrow]) do |(p, d)|
        players(p).availabilities.create!(playdate: d,
          status: Availability::STATUS_JA)
      end

      # today is best, tomorrow is good
      players(:admin).availabilities.create!(playdate: today,
        status: Availability::STATUS_JA)

      get :index, params: {}, session: playersession

      aggregate_failures do
        expect(response.body).to have_css "tr.summary td:nth-of-type(1)", text: "Beste"
        expect(response.body).to have_css "tr.summary td:nth-of-type(2)", text: "Ja"
      end
    end

    it "index_with_house_better_than_without" do
      [today, tomorrow].each do |d|
        players(:matijs).availabilities.create!(playdate: d,
          status: Availability::STATUS_JA)
      end

      # today is good, tomorrow is best
      players(:robert).availabilities.create!(playdate: today,
        status: Availability::STATUS_JA)

      players(:robert).availabilities.create!(playdate: tomorrow,
        status: Availability::STATUS_HUIS)

      get :index, params: {}, session: playersession

      aggregate_failures do
        expect(response.body).to have_css "tr.summary td:nth-of-type(1)", text: "Ja"
        expect(response.body).to have_css "tr.summary td:nth-of-type(2)", text: "Beste"
      end
    end
  end

  describe "#edit" do
    before do
      get :edit, params: {}, session: playersession
    end

    it "renders the edit template" do
      aggregate_failures do
        expect(response).to be_successful
        expect(response).to render_template "edit"
        expect(response.body).to have_css "h1", text: "Beschikbaarheid bewerken"
      end
    end

    it "assigns available playdates for rendering" do
      aggregate_failures do
        expect(assigns(:playdates)).not_to be_nil
        expect(assigns(:playdates).count).to eq 2
      end
    end

    it "creates an availability selector for each playdate" do
      elements = Capybara.string(response.body).find_css("select")
      aggregate_failures do
        expect(elements.count).to eq assigns(:playdates).count
        expect(elements).to all have_css "option", text: "Ja"
        expect(elements).to all have_css "option", text: "Nee"
        expect(elements).to all have_css "option", text: "Misschien"
        expect(elements).to all have_css "option", text: "Huis"
      end
    end
  end

  it "update" do
    post :update,
      params: { availability: { 1 => { status: 2 }, 2 => { status: 3 } } },
      session: { user_id: players(:robert).id }
    aggregate_failures do
      expect(response).to redirect_to controller: "main", action: "index"
      expect(Availability.count).to eq 4
      newavs = players(:robert).availabilities.sort_by(&:playdate_id)
      expect(newavs.map { |a| [a.playdate_id, a.status] }.flatten).to eq [1, 2, 2, 3]
    end
  end

  describe "#feed" do
    it "renders the feed and feed table" do
      get :feed, params: { format: "xml" }, session: {}
      aggregate_failures do
        expect(response).to be_successful
        expect(response).to render_template "feed"
        expect(response).to render_template "feed_table"
      end
    end

    it "assigns needed values" do
      get :feed, params: { format: "xml" }, session: {}
      aggregate_failures do
        expect(assigns(:playdates)).not_to be_nil
        expect(assigns(:link)).not_to be_nil
        expect(assigns(:updated_at)).to be_nil
        expect(assigns(:date)).to be_nil
        expect(assigns(:stats)).not_to be_nil
      end
    end

    it "sets updated datetime to latest updated availability" do
      av = tomorrow.availabilities
        .create!(player_id: players(:robert).id, status: 1)

      get :feed, params: { format: "xml" }, session: {}

      aggregate_failures do
        expect(response).to be_successful
        expect(av.updated_at.to_s).to eq assigns(:updated_at).to_s
      end
    end
  end

  private

  def playersession
    { user_id: players(:matijs).id }
  end

  def adminsession
    { user_id: players(:admin).id }
  end
end
