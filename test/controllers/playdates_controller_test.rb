# frozen_string_literal: true

require "test_helper"

class PlaydatesControllerTest < ActionController::TestCase
  render_views!

  def test_authorization
    playersession = { user_id: players(:matijs).id }
    [
      [{}, "session", "new"],
      [playersession, "main", "index"]
    ].each do |session, controller, action|
      [:destroy, :index, :new, :show, :prune].each do |a|
        [:get, :post].each do |m|
          method(m).call(a, params: { id: 1 }, session: session)
          assert_redirected_to controller: controller,
                               action: action
        end
      end
    end
  end

  def test_destroy
    pd = Playdate.find(1)
    assert_not_nil pd
    num_avs = Availability.count
    num_pd_avs = pd.availabilities.count
    assert num_pd_avs > 0, "Test won't work if pd has no availabilities"

    delete "destroy", params: { id: 1 }, session: adminsession
    assert_response :redirect
    assert_redirected_to controller: "playdates", action: "index"

    assert_raise(ActiveRecord::RecordNotFound) { Playdate.find(1) }
    assert_equal num_avs - num_pd_avs, Availability.count
  end

  def test_no_route_to_destroy_without_id
    assert_not_routed action: "destroy", controller: "playdates"
  end

  def test_index
    get "index", params: {}, session: adminsession

    assert_response :success
    assert_template "index"

    assert_not_nil assigns(:playdates)

    assert_select "h1", "Speeldagen"

    assert_select "a[href=?][data-method=delete]", playdate_path(1), "Verwijderen"
  end

  def test_new
    get "new", params: {}, session: adminsession

    assert_response :success
    assert_template "new"

    assert_not_nil assigns(:playdate)

    assert_select "h1", "Nieuwe speeldagen"
    assert_select "form[action=?]", playdates_path
  end

  def test_create
    num_playdates = Playdate.count

    post "create", params: { playdate: { day: "2006-03-11" } }, session: adminsession

    assert_response :redirect
    assert_redirected_to controller: "playdates", action: "index"

    assert_equal num_playdates + 1, Playdate.count
  end

  def test_create_with_range
    num_playdates = Playdate.count

    post "create", params: { period: 2, daytype: 6 }, session: adminsession

    assert_response :redirect
    assert_redirected_to controller: "playdates", action: "index"

    assert_operator Playdate.count, :>=, num_playdates + 4
    assert_operator Playdate.count, :<=, num_playdates + 10
  end

  def test_create_with_range_invalid_period
    post "create", params: { period: 3, daytype: 6 }, session: adminsession

    assert_template :new
  end

  def test_create_with_range_invalid_day_type
    post "create", params: { period: 2, daytype: 7 }, session: adminsession

    assert_template :new
  end

  def test_show
    get "show", params: { id: 1 }, session: adminsession

    assert_response :success
    assert_template "show"

    assert_not_nil assigns(:playdate)
    assert assigns(:playdate).valid?

    assert_select "h1", "Speeldag: 2006-02-10"

    assert_select "a[href=?]", edit_playdate_availability_path(1, 1)
    # XXX: Rather technical test.
    assert_select "a[href=?][data-method=delete]", playdate_availability_path(1, 1)
  end

  def test_no_route_to_show_without_id
    assert_not_routed action: "show", controller: "playdates"
  end

  def test_prune_using_post
    num_playdates = Playdate.count
    assert num_playdates == 4
    post "prune", params: {}, session: adminsession

    assert_response :redirect
    assert_redirected_to controller: "playdates", action: "index"
    assert Playdate.count == 2
    assert Playdate.all.map(&:id).sort == [3, 4]
  end

  def adminsession
    { user_id: players(:admin).id }
  end
end
