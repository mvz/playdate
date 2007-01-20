require File.dirname(__FILE__) + '/../test_helper'
require 'availabilities_controller'

# Re-raise errors caught by the controller.
class AvailabilitiesController; def rescue_action(e) raise e end; end

class AvailabilitiesControllerTest < Test::Unit::TestCase
  fixtures :players
  fixtures :playdates
  fixtures :availabilities

  def setup
    @controller = AvailabilitiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @playersession = {:user_id => players(:matijs).id }
  end

  def assert_redirect_to_playdate_view(id)
    assert_redirected_to :controller => 'playdates', :action => 'view', :id => "#{id}"
  end

  def test_authorization
    [:destroy, :edit, :list, :new, :show].each do |a|
      [:get, :post].each do |m|
        method(m).call(a, {:playdate_id => 1}, {})
        assert_redirected_to :controller => "login", :action => "login"
      end
    end
  end

  # Destroy using get: Go to edit
  def test_destroy_using_get
    assert_not_nil Availability.find(1)

    get 'destroy', {:playdate_id => 1, :availability_id => 1}, @playersession
    assert_response :redirect
    assert_redirected_to :action => 'edit'
    assert flash.has_key?(:notice)

    assert_not_nil Availability.find(1)
  end

  # Destroy using post: Destroy, go to view of playdate (which has a list
  # of availabilities)
  def test_destroy_using_post
    assert_not_nil Availability.find(1)

    post 'destroy', {:playdate_id => 1, :availability_id => 1}, @playersession
    assert_response :redirect
    assert_redirect_to_playdate_view(1)

    assert_raise(ActiveRecord::RecordNotFound) { Availability.find(1) }
  end

  # Destroy without availability-id: Go to view of playdate (which has a
  # list of availabilities)
  def test_destroy_without_id
    assert_not_nil Availability.find(1)

    post 'destroy', {:playdate_id => 1}, @playersession
    assert_response :redirect
    assert_redirect_to_playdate_view(1)
    assert flash.has_key?(:notice)

    assert_not_nil Availability.find(1)
  end

  # Edit using get: Show edit screen.
  def test_edit_using_get
    get 'edit', {:playdate_id => 1, :availability_id => 1}, @playersession

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:availability)
    assert assigns(:availability).valid?

    # Unknown id combo
    get 'edit', {:playdate_id => 2, :availability_id => 1}, @playersession
    assert_response :redirect
    assert_redirect_to_playdate_view(2)
  end

  # Edit using post: Edit, then return to list of availabilities for
  # playdate.
  def test_edit_using_post
    post 'edit', {:playdate_id => 1, :availability_id => 1}, @playersession

    assert_response :redirect
    assert_redirect_to_playdate_view(1)
  end

  def test_edit_without_id
    post 'edit', {:playdate_id => 1}, @playersession
    assert_response :redirect
    assert_redirect_to_playdate_view(1)
    assert flash.has_key?(:notice)
  end

  def test_list
    assert_raise ActionController::UnknownAction do
      get 'list', {:playdate_id => 1}, @playersession
    end
  end

  def test_new_using_get
    get 'new', {:playdate_id => 1}, @playersession

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:availability)
  end

  def test_new_using_post
    num_availabilities = Availability.count

    post 'new', {:playdate_id => playdates(:friday).id,
      :availability => {:player_id => players(:robert).id, :status => 1 }},
      @playersession

    assert_response :redirect
    assert_redirect_to_playdate_view(1)

    assert_equal num_availabilities + 1, Availability.count
  end

  def test_show
    get 'show', {:playdate_id => 1, :availability_id => 1}, @playersession

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:availability)
    assert assigns(:availability).valid?
  end

  def test_show_without_id
    get 'show', {:playdate_id => 1}, @playersession

    assert_response :redirect
    assert_redirect_to_playdate_view(1)
    assert flash.has_key?(:notice)
  end
end
