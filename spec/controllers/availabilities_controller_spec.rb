# frozen_string_literal: true

require "rails_helper"

RSpec.describe AvailabilitiesController, type: :controller do
  render_views
  fixtures :players, :playdates, :availabilities

  describe "when not logged in" do
    [:destroy, :create, :update, :edit, :new].product([:get, :post]) do |(a, m)|
      it "requires login for #{m} #{a}" do
        send m, a, params: {playdate_id: 1, id: 1}
        assert_redirected_to login_path
      end
    end
  end

  describe "when logged in as a regular player" do
    let(:playersession) { {user_id: players(:matijs).id} }

    [:destroy, :create, :update, :edit, :new].product([:get, :post]) do |(a, m)|
      it "denies access for #{m} #{a}" do
        send m, a, params: {playdate_id: 1, id: 1}, session: playersession
        assert_redirected_to root_path
      end
    end
  end

  # Destroy, go to view of playdate (which has a list of availabilities)
  it "destroy" do
    refute_nil Availability.find(1)

    delete "destroy", params: {playdate_id: 1, id: 1}, session: adminsession
    assert_response :redirect
    assert_redirect_to_playdate_view(1)

    assert_raises(ActiveRecord::RecordNotFound) { Availability.find(1) }
  end

  # Edit: Show edit screen.
  it "edit" do
    get "edit", params: {playdate_id: 1, id: 1}, session: adminsession

    assert_response :success
    assert_template "edit"

    refute_nil assigns(:availability)
    assert assigns(:availability).valid?

    assert_select "h1", "Editing availability"

    # XXX: Rather technical test to check form will do PATCH playdate_availability_path(1)
    assert_select "form[action=?] input[value='patch']", playdate_availability_path(1, 1)

    # Unknown id combo
    expect { get "edit", params: {playdate_id: 2, id: 1}, session: adminsession }
      .to raise_error ActiveRecord::RecordNotFound
  end

  # Update: Edit, then return to list of availabilities for playdate.
  it "update" do
    put :update,
      params: {
        playdate_id: 1,
        id: 1,
        availability: {status: Availability::STATUS_JA}
      },
      session: adminsession

    assert_response :redirect
    assert_redirect_to_playdate_view(1)
  end

  it "new" do
    get "new", params: {playdate_id: 1}, session: adminsession

    assert_response :success
    assert_template "new"

    refute_nil assigns(:availability)

    assert_select "h1", "New availability"
  end

  it "create" do
    num_availabilities = Availability.count

    post :create,
      params: {
        playdate_id: playdates(:friday).id,
        availability: {player_id: players(:robert).id, status: 1}
      },
      session: adminsession

    assert_response :redirect
    assert_redirect_to_playdate_view(1)

    assert_equal num_availabilities + 1, Availability.count
  end

  private

  def assert_redirect_to_playdate_view(id)
    assert_redirected_to controller: "playdates", action: "show", id: id.to_s
  end

  def adminsession
    {user_id: players(:admin).id}
  end
end
