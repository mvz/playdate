require File.dirname(__FILE__) + '/../test_helper'

class AvailabilitiesControllerTest < ActionController::TestCase
  def assert_redirect_to_playdate_view(id)
    assert_redirected_to :controller => 'playdates', :action => 'show', :id => "#{id}"
  end

  def test_authorization
    playersession = {:user_id => players(:matijs).id }
    [:destroy, :edit, :index, :new, :show].each do |a|
      [:get, :post].each do |m|
        [
          [{}, "login", "login"],
          [playersession, "main", "index"]
        ].each do |session,controller,action|
          method(m).call(a, {:playdate_id => 1, :id => 1}, session)
          assert_redirected_to(:controller => controller,
                               :action => action)
        end
      end
    end
  end

  # Destroy using get: Go to edit
  def test_destroy_using_get
    assert_not_nil Availability.find(1)

    get 'destroy', {:playdate_id => 1, :id => 1}, adminsession

    assert_not_nil Availability.find(1)

    assert_response :redirect

    assert flash.has_key?(:notice)
    assert_equal 'Click Destroy to destroy the availability.',
      flash[:notice]

    assert_redirected_to :controller => 'availabilities',
      :action => 'edit', :playdate_id => 1, :id => 1
  end

  # Destroy using post: Destroy, go to view of playdate (which has a list
  # of availabilities)
  def test_destroy_using_post
    assert_not_nil Availability.find(1)

    post 'destroy', {:playdate_id => 1, :id => 1}, adminsession
    assert_response :redirect
    assert_redirect_to_playdate_view(1)

    assert_raise(ActiveRecord::RecordNotFound) { Availability.find(1) }
  end

  # Destroy without availability-id: No route.
  def test_destroy_without_id
    assert_not_nil Availability.find(1)

    assert_raise(ActionController::RoutingError) do
      post 'destroy', {:playdate_id => 1}, adminsession
    end

    assert_not_nil Availability.find(1)
  end

  # Edit using get: Show edit screen.
  def test_edit_using_get
    get 'edit', {:playdate_id => 1, :id => 1}, adminsession

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:availability)
    assert assigns(:availability).valid?

    # Unknown id combo
    get 'edit', {:playdate_id => 2, :id => 1}, adminsession
    assert_response :redirect
    assert_redirect_to_playdate_view(2)
  end

  # Edit using post: Edit, then return to list of availabilities for
  # playdate.
  def test_edit_using_post
    post 'edit', {:playdate_id => 1, :id => 1}, adminsession

    assert_response :redirect
    assert_redirect_to_playdate_view(1)
  end

  def test_edit_without_id
    assert_raise(ActionController::RoutingError) do
      post 'edit', {:playdate_id => 1}, adminsession
    end
  end

  def test_index
    get 'index', {:playdate_id => 1}, adminsession
    assert_response :redirect
    assert_redirect_to_playdate_view(1)
  end

  def test_new_using_get
    get 'new', {:playdate_id => 1}, adminsession

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:availability)
  end

  def test_new_using_post
    num_availabilities = Availability.count

    post 'new', {:playdate_id => playdates(:friday).id,
      :availability => {:player_id => players(:robert).id, :status => 1 }},
      adminsession

    assert_response :redirect
    assert_redirect_to_playdate_view(1)

    assert_equal num_availabilities + 1, Availability.count
  end

  def test_show
    get 'show', {:playdate_id => 1, :id => 1}, adminsession

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:availability)
    assert assigns(:availability).valid?
  end

  def test_show_without_id
    assert_raise(ActionController::RoutingError) do
      get 'show', {:playdate_id => 1}, adminsession
    end
  end

  def adminsession
    {:user_id => players(:admin).id }
  end
end
