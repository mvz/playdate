# frozen_string_literal: true

require "test_helper"

class MainControllerTest < ActionController::TestCase
  render_views!
  MainController::MIN_PLAYERS = 2

  def test_authorization
    [:index, :edit, :update].product([:get, :post]) do |(a, m)|
      method(m).call(a, params: {}, session: {})
      assert_redirected_to controller: "session", action: "new"
    end
  end

  def test_index_as_user
    get :index, params: {}, session: playersession
    assert_response :success
    assert_template "index"
    assert_not_nil assigns(:playdates)
    assert_equal [playdates(:today), playdates(:tomorrow)], assigns(:playdates)
    assert_not_nil assigns(:stats)
    assert_select 'a[href="/more"]'
    assert_select 'a[href="/playdates"]', false

    assert_select "h1", "Playdate! The Application"
  end

  def test_index_as_admin
    get :index, params: {}, session: adminsession
    assert_response :success
    assert_template "index"
    assert_not_nil assigns(:playdates)
    assert_not_nil assigns(:stats)
    assert_select 'a[href="/playdates"]'
  end

  def test_index_all_dates_present
    # today and tomorrow are already there
    startdate = Time.zone.today + 2
    enddate = Time.zone.today.next_month.end_of_month
    startdate.upto(enddate) do |day|
      next unless MainHelper::CANDIDATE_WEEKDAYS.include?(day.wday)

      Playdate.new(day: day).save!
    end
    get :index, params: {}, session: playersession
    assert_select 'a[href="/more"]', false
  end

  def test_index_shows_no_for_bad_day
    [:matijs, :robert].each do |p|
      players(p).availabilities.build.tap do |av|
        av.playdate = playdates(:today)
        av.status = Availability::STATUS_NEE
      end.save!
    end

    get :index, params: {}, session: playersession

    assert_select "tr.summary td:first-of-type", "Nee"
  end

  def test_index_shows_empty_for_neutral_day
    get :index, params: {}, session: playersession

    assert_select "tr.summary td:first-of-type", ""
  end

  def test_index_shows_best_for_only_good_day
    [:matijs, :robert].each do |p|
      players(p).availabilities.build.tap do |av|
        av.playdate = playdates(:today)
        av.status = Availability::STATUS_JA
      end.save!
    end

    get :index, params: {}, session: playersession

    assert_select "tr.summary td:first-of-type", "Beste"
  end

  def test_index_both_days_good_but_first_is_best
    [:matijs, :robert].product([:today, :tomorrow]) do |(p, d)|
      av = players(p).availabilities.build
      av.playdate = playdates(d)
      av.status = Availability::STATUS_JA
      av.save!
    end

    # today is best, tomorrow is good
    av = players(:admin).availabilities.build
    av.playdate = playdates(:today)
    av.status = Availability::STATUS_JA
    av.save!

    get :index, params: {}, session: playersession

    assert_select "tr.summary td:nth-of-type(1)", "Beste"
    assert_select "tr.summary td:nth-of-type(2)", "Ja"
  end

  def test_index_with_house_better_than_without
    [:today, :tomorrow].each do |d|
      players(:matijs).availabilities.build.tap do |av|
        av.playdate = playdates(d)
        av.status = Availability::STATUS_JA
      end.save!
    end

    # today is good, tomorrow is best
    players(:robert).availabilities.build.tap do |av|
      av.playdate = playdates(:today)
      av.status = Availability::STATUS_JA
    end.save!

    players(:robert).availabilities.build.tap do |av|
      av.playdate = playdates(:tomorrow)
      av.status = Availability::STATUS_HUIS
    end.save!

    get :index, params: {}, session: playersession

    assert_select "tr.summary td:nth-of-type(1)", "Ja"
    assert_select "tr.summary td:nth-of-type(2)", "Beste"
  end

  def test_edit
    get :edit, params: {}, session: playersession
    assert_response :success
    assert_template "edit"
    assert_not_nil assigns(:playdates)
    assert_equal 2, assigns(:playdates).count
    assert_select "select", assigns(:playdates).count
    assert_select "select" do |elements|
      elements.each do |element|
        assert_select element, "option", "Ja"
        assert_select element, "option", "Nee"
        assert_select element, "option", "Misschien"
        assert_select element, "option", "Huis"
      end
    end
    assert_select "h1", "Beschikbaarheid bewerken"
  end

  def test_update
    post :update,
         params: { availability: { 1 => { status: 2 }, 2 => { status: 3 } } },
         session: { user_id: players(:robert).id }
    assert_response :redirect
    assert_redirected_to controller: "main", action: "index"
    assert Availability.count == 4
    newavs = players(:robert).availabilities.sort_by(&:playdate_id)
    assert newavs.map { |a| [a.playdate_id, a.status] }.flatten == [1, 2, 2, 3]
  end

  def test_feed
    get :feed, params: { format: "xml" }, session: {}
    assert_response :success
    assert_template "feed"
    assert_template "feed_table"
    assert_not_nil assigns(:playdates)
    assert_not_nil assigns(:link)
    assert_nil assigns(:updated_at)
    assert_nil assigns(:date)

    av = playdates(:tomorrow).availabilities
      .build(player_id: players(:robert).id, status: 1)
    av.save!

    get :feed, params: { format: "xml" }, session: {}
    assert_response :success
    assert_equal assigns(:updated_at).to_s, av.updated_at.to_s
    assert_not_nil assigns(:stats)
  end

  def playersession
    { user_id: players(:matijs).id }
  end

  def adminsession
    { user_id: players(:admin).id }
  end
end
