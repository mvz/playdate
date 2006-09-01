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

  def test_authorization
    [:destroy, :edit, :list, :new, :show].each do |a|
      [:get, :post].each do |m|
        method(m).call(a, {}, {})
        assert_redirected_to :controller => "login", :action => "login"
      end
    end
  end

  def test_destroy_using_get
    assert_not_nil Availability.find(1)

    get 'destroy', {:id => 1}, @playersession
    assert_response :redirect
    assert_redirected_to :action => 'edit'

    assert_not_nil Availability.find(1)
  end

  def test_destroy_using_post
    assert_not_nil Availability.find(1)

    post 'destroy', {:id => 1}, @playersession
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) { Availability.find(1) }
  end

  def test_destroy_without_id
    assert_not_nil Availability.find(1)

    post 'destroy', {}, @playersession
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)

    assert_not_nil Availability.find(1)
  end

  def test_edit_using_get
    get 'edit', {:id => 1}, @playersession

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:availability)
    assert assigns(:availability).valid?
  end

  def test_edit_using_post
    post 'edit', {:id => 1, :player_id => 2, :playdate_id => 1},
      @playersession
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_edit_without_id
    post 'edit', {}, @playersession
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)
  end

  def test_list
    get 'list', {}, @playersession

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:availabilities)
  end

  def test_new_using_get
    get 'new', {}, @playersession

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:availability)
  end

  def test_new_using_post
    num_availabilities = Availability.count

    post 'new', {:availability => {
      :player_id => players(:robert).id,
      :playdate_id => playdates(:friday).id, :status => 1 }},
      @playersession

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_availabilities + 1, Availability.count
  end

  def test_show
    get 'show', {:id => 1}, @playersession

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:availability)
    assert assigns(:availability).valid?
  end

  def test_show_without_id
    get 'show', {}, @playersession

    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)
  end
end
