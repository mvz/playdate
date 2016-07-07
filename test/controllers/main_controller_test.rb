require 'test_helper'

class MainControllerTest < ActionController::TestCase
  render_views!
  MainController::MIN_PLAYERS = 2

  def test_authorization
    [:index, :edit, :more].each do |a|
      [:get, :post].each do |m|
        method(m).call(a, params: {}, session: {})
        assert_redirected_to controller: 'login', action: 'login'
      end
    end
  end

  def test_index_as_user
    get :index, params: {}, session: playersession
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:playdates)
    assert_equal [playdates(:today), playdates(:tomorrow)], assigns(:playdates)
    assert_not_nil assigns(:stats)
    assert_select 'a[href="/more"]'
    assert_select 'a[href="/playdates"]', false

    assert_select 'h1', 'Playdate! The Application'
  end

  def test_index_as_admin
    get :index, params: {}, session: adminsession
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:playdates)
    assert_not_nil assigns(:stats)
    assert_select 'a[href="/playdates"]'
  end

  def test_index_all_dates_present
    # today and tomorrow are already there
    startdate = Time.zone.today + 2
    enddate = Time.zone.today.next_month.end_of_month
    startdate.upto(enddate) do |day|
      next unless [5, 6].include?(day.wday)
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

    assert_select 'tr.summary td:first-of-type', 'Nee'
  end

  def test_index_shows_empty_for_neutral_day
    get :index, params: {}, session: playersession

    assert_select 'tr.summary td:first-of-type', ''
  end

  def test_index_shows_best_for_only_good_day
    [:matijs, :robert].each do |p|
      players(p).availabilities.build.tap do |av|
        av.playdate = playdates(:today)
        av.status = Availability::STATUS_JA
      end.save!
    end

    get :index, params: {}, session: playersession

    assert_select 'tr.summary td:first-of-type', 'Beste'
  end

  def test_index_both_days_good_but_first_is_best
    [:matijs, :robert].each do |p|
      [:today, :tomorrow].each do |d|
        players(p).availabilities.build.tap do |av|
          av.playdate = playdates(d)
          av.status = Availability::STATUS_JA
        end.save!
      end
    end

    # today is best, tomorrow is good
    players(:admin).availabilities.build.tap do |av|
      av.playdate = playdates(:today)
      av.status = Availability::STATUS_JA
    end.save!

    get :index, params: {}, session: playersession

    assert_select 'tr.summary td:nth-of-type(1)', 'Beste'
    assert_select 'tr.summary td:nth-of-type(2)', 'Ja'
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

    assert_select 'tr.summary td:nth-of-type(1)', 'Ja'
    assert_select 'tr.summary td:nth-of-type(2)', 'Beste'
  end

  def test_edit_using_get
    get :edit, params: {}, session: playersession
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:playdates)
    assert_equal 2, assigns(:playdates).count
    assert_select 'select', assigns(:playdates).count
    assert_select 'select' do |elements|
      elements.each do |element|
        assert_select element, 'option', 'Ja'
        assert_select element, 'option', 'Nee'
        assert_select element, 'option', 'Misschien'
        assert_select element, 'option', 'Huis'
      end
    end
    assert_select 'h1', 'Beschikbaarheid bewerken'
  end

  def test_edit_using_post
    post :edit,
      params: { availability: { 1 => { status: 2 }, 2 => { status: 3 } } },
      session: { user_id: players(:robert).id }
    assert_response :redirect
    assert_redirected_to controller: 'main', action: 'index'
    assert Availability.count == 4
    newavs = players(:robert).availabilities.sort_by(&:playdate_id)
    assert newavs.map { |a| [a.playdate_id, a.status] }.flatten == [1, 2, 2, 3]
  end

  def test_more_using_get
    oldcount = Playdate.count
    get :more, params: {}, session: playersession
    assert_response :success
    assert_template 'more'
    assert_select 'form'
    assert_equal Playdate.count, oldcount
    assert_select 'h1', 'Speeldagen toevoegen'
  end

  # FIXME: Use fixed dates rather than relying on logic based on the current
  # date. Test each case (only this month, also next month) separately, with
  # seperate checks for the borderline dates.
  def test_more_using_post
    oldcount = Playdate.count
    post :more, params: {}, session: playersession
    assert_response :redirect
    assert_redirected_to controller: 'main', action: 'index'
    assert_operator Playdate.count, :>, oldcount + 1
    assert_operator Playdate.count, :<=, oldcount + 12
    startdate = Time.zone.today + 1
    enddate = if startdate + 7 <= Time.zone.today.end_of_month
                Time.zone.today.end_of_month
              else
                Time.zone.today.next_month.end_of_month
              end
    (startdate + 1).upto(enddate) do |day|
      if [5, 6].include?(day.wday)
        assert_not_nil Playdate.find_by_day(day)
      else
        assert_nil Playdate.find_by_day(day)
      end
    end
  end

  def test_feed
    get :feed, params: { format: 'xml' }, session: {}
    assert_response :success
    assert_template 'feed'
    assert_template 'feed_table'
    assert_not_nil assigns(:playdates)
    assert_not_nil assigns(:link)
    assert_nil assigns(:updated_at)
    assert_nil assigns(:date)

    av = playdates(:tomorrow).availabilities.build(player_id: players(:robert).id, status: 1)
    av.save!

    get :feed, params: { format: 'xml' }, session: {}
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
