# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlaydatesController, type: :controller do
  render_views
  fixtures :players, :playdates, :availabilities

  describe "when not logged in" do
    [:destroy, :index, :new, :show, :prune].product([:get, :post]) do |(a, m)|
      it "requires login for #{m} #{a}" do
        send m, a, params: {id: 1}
        assert_redirected_to login_path
      end
    end
  end

  describe "when logged in as a regular player" do
    let(:playersession) { {user_id: players(:matijs).id} }

    [:destroy, :index, :new, :show, :prune].product([:get, :post]) do |(a, m)|
      it "denies access for #{m} #{a}" do
        send m, a, params: {id: 1}, session: playersession
        assert_redirected_to root_path
      end
    end
  end

  it "destroy" do
    pd = Playdate.find(1)
    refute_nil pd
    num_avs = Availability.count
    num_pd_avs = pd.availabilities.count
    assert num_pd_avs > 0, "Test won't work if pd has no availabilities"

    delete "destroy", params: {id: 1}, session: adminsession
    assert_response :redirect
    assert_redirected_to controller: "playdates", action: "index"

    assert_raises(ActiveRecord::RecordNotFound) { Playdate.find(1) }
    assert_equal num_avs - num_pd_avs, Availability.count
  end

  it "index" do
    get "index", params: {}, session: adminsession

    assert_response :success
    assert_template "index"

    refute_nil assigns(:playdates)

    assert_select "h1", "Speeldagen"

    assert_select "a[href=?][data-turbo-method=delete]", playdate_path(1), "Verwijderen"
  end

  it "new" do
    get "new", params: {}, session: adminsession

    assert_response :success
    assert_template "new"

    refute_nil assigns(:playdate)

    assert_select "h1", "Nieuwe speeldagen"
    assert_select "form[action=?]", playdates_path
  end

  it "create" do
    num_playdates = Playdate.count

    post "create", params: {playdate: {day: "2006-03-11"}}, session: adminsession

    assert_response :redirect
    assert_redirected_to controller: "playdates", action: "index"

    assert_equal num_playdates + 1, Playdate.count
  end

  it "create_with_range" do
    num_playdates = Playdate.count

    post "create", params: {period: 2, daytype: 6}, session: adminsession

    assert_response :redirect
    assert_redirected_to controller: "playdates", action: "index"

    assert_operator Playdate.count, :>=, num_playdates + 4
    assert_operator Playdate.count, :<=, num_playdates + 10
  end

  it "create_with_range_invalid_period" do
    post "create", params: {period: 3, daytype: 6}, session: adminsession

    assert_template :new
  end

  it "create_with_range_invalid_day_type" do
    post "create", params: {period: 2, daytype: 7}, session: adminsession

    assert_template :new
  end

  it "show" do
    get "show", params: {id: 1}, session: adminsession

    assert_response :success
    assert_template "show"

    refute_nil assigns(:playdate)
    assert assigns(:playdate).valid?

    assert_select "h1", "Speeldag: 2006-02-10"

    assert_select "a[href=?]", edit_playdate_availability_path(1, 1)
    # XXX: Rather technical test.
    assert_select "a[href=?][data-turbo-method=delete]", playdate_availability_path(1, 1)
  end

  it "prune_using_post" do
    num_playdates = Playdate.count
    assert_equal 4, num_playdates
    post "prune", params: {}, session: adminsession

    assert_response :redirect
    assert_redirected_to controller: "playdates", action: "index"
    assert_equal 2, Playdate.count
    assert_equal [3, 4], Playdate.all.map(&:id).sort
  end

  private

  def adminsession
    {user_id: players(:admin).id}
  end
end
