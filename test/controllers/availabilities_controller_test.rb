require 'test_helper'

class AvailabilitiesControllerTest < ActionController::TestCase
  render_views!

  def assert_redirect_to_playdate_view(id)
    assert_redirected_to controller: 'playdates', action: 'show', id: "#{id}"
  end

  def test_authorization
    playersession = { user_id: players(:matijs).id }
    [
      [{}, 'login', 'login'],
      [playersession, 'main', 'index']
    ].each do |session, controller, action|
      [:destroy, :create, :update, :edit, :new].each do |a|
        [:get, :post].each do |m|
          method(m).call(a, { playdate_id: 1, id: 1 }, session)
          assert_redirected_to(controller: controller,
                               action: action)
        end
      end
    end
  end

  # Destroy, go to view of playdate (which has a list of availabilities)
  def test_destroy
    assert_not_nil Availability.find(1)

    delete 'destroy', { playdate_id: 1, id: 1 }, adminsession
    assert_response :redirect
    assert_redirect_to_playdate_view(1)

    assert_raise(ActiveRecord::RecordNotFound) { Availability.find(1) }
  end

  def test_no_route_to_destroy_without_id
    assert_not_routed action: 'destroy', controller: 'availabilities'
    assert_not_routed action: 'destroy', controller: 'availabilities', playdate_id: 1
  end

  # Edit: Show edit screen.
  def test_edit
    get 'edit', { playdate_id: 1, id: 1 }, adminsession

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:availability)
    assert assigns(:availability).valid?

    assert_select 'h1', 'Editing availability'

    # XXX: Rather technical test to check form will do PATCH playdate_availability_path(1)
    assert_select "form[action=?] input[value='patch']", playdate_availability_path(1, 1)

    # Unknown id combo
    proc {
      get 'edit', { playdate_id: 2, id: 1 }, adminsession
    }.must_raise ActiveRecord::RecordNotFound
  end

  # Update: Edit, then return to list of availabilities for playdate.
  def test_update
    put 'update', { playdate_id: 1,
                    id: 1,
                    availability: { status: Availability::STATUS_JA } }, adminsession

    assert_response :redirect
    assert_redirect_to_playdate_view(1)
  end

  def test_no_route_to_edit_without_id
    assert_not_routed action: 'edit', controller: 'availabilities'
    assert_not_routed action: 'edit', controller: 'availabilities', playdate_id: 1
  end

  def test_new
    get 'new', { playdate_id: 1 }, adminsession

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:availability)

    assert_select 'h1', 'New availability'
  end

  def test_create
    num_availabilities = Availability.count

    post 'create', { playdate_id: playdates(:friday).id,
                     availability: { player_id: players(:robert).id, status: 1 } },
      adminsession

    assert_response :redirect
    assert_redirect_to_playdate_view(1)

    assert_equal num_availabilities + 1, Availability.count
  end

  def adminsession
    { user_id: players(:admin).id }
  end
end