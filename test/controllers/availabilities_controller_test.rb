# frozen_string_literal: true

require "test_helper"

class AvailabilitiesControllerTest < ActionController::TestCase
  render_views!

  def assert_redirect_to_playdate_view(id)
    assert_redirected_to controller: "playdates", action: "show", id: id.to_s
  end

  describe "when not logged in" do
    [:destroy, :create, :update, :edit, :new].product([:get, :post]) do |(a, m)|
      it "requires login for #{m} #{a}" do
        send m, a, params: { playdate_id: 1, id: 1 }
        assert_redirected_to login_path
      end
    end
  end

  describe "when logged in as a regular player" do
    let(:playersession) { { user_id: players(:matijs).id } }

    [:destroy, :create, :update, :edit, :new].product([:get, :post]) do |(a, m)|
      it "denies access for #{m} #{a}" do
        send m, a, params: { playdate_id: 1, id: 1 }, session: playersession
        assert_redirected_to root_path
      end
    end
  end

  # Destroy, go to view of playdate (which has a list of availabilities)
  def test_destroy
    assert_not_nil Availability.find(1)

    delete "destroy", params: { playdate_id: 1, id: 1 }, session: adminsession
    assert_response :redirect
    assert_redirect_to_playdate_view(1)

    assert_raise(ActiveRecord::RecordNotFound) { Availability.find(1) }
  end

  def test_no_route_to_destroy_without_id
    assert_not_routed action: "destroy", controller: "availabilities"
    assert_not_routed action: "destroy", controller: "availabilities", playdate_id: 1
  end

  # Edit: Show edit screen.
  def test_edit
    get "edit", params: { playdate_id: 1, id: 1 }, session: adminsession

    assert_response :success
    assert_template "edit"

    assert_not_nil assigns(:availability)
    assert assigns(:availability).valid?

    assert_select "h1", "Editing availability"

    # XXX: Rather technical test to check form will do PATCH playdate_availability_path(1)
    assert_select "form[action=?] input[value='patch']", playdate_availability_path(1, 1)

    # Unknown id combo
    _(proc { get "edit", params: { playdate_id: 2, id: 1 }, session: adminsession })
      .must_raise ActiveRecord::RecordNotFound
  end

  # Update: Edit, then return to list of availabilities for playdate.
  def test_update
    put("update",
        params:
        {
          playdate_id: 1,
          id: 1,
          availability: { status: Availability::STATUS_JA }
        },
        session: adminsession)

    assert_response :redirect
    assert_redirect_to_playdate_view(1)
  end

  def test_no_route_to_edit_without_id
    assert_not_routed action: "edit", controller: "availabilities"
    assert_not_routed action: "edit", controller: "availabilities", playdate_id: 1
  end

  def test_new
    get "new", params: { playdate_id: 1 }, session: adminsession

    assert_response :success
    assert_template "new"

    assert_not_nil assigns(:availability)

    assert_select "h1", "New availability"
  end

  def test_create
    num_availabilities = Availability.count

    post("create",
         params: {
           playdate_id: playdates(:friday).id,
           availability: { player_id: players(:robert).id, status: 1 }
         },
         session: adminsession)

    assert_response :redirect
    assert_redirect_to_playdate_view(1)

    assert_equal num_availabilities + 1, Availability.count
  end

  def adminsession
    { user_id: players(:admin).id }
  end
end
