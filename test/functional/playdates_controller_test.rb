require File.dirname(__FILE__) + '/../test_helper'
require 'playdates_controller'

# Re-raise errors caught by the controller.
class PlaydatesController; def rescue_action(e) raise e end; end

class PlaydatesControllerTest < Test::Unit::TestCase
  fixtures :playdates

  def setup
    @controller = PlaydatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_destroy_using_get
    assert_not_nil Playdate.find(1)

    get 'destroy', :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'edit'

    assert_not_nil Playdate.find(1)
  end

  def test_destroy_using_post
    assert_not_nil Playdate.find(1)

    post 'destroy', :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) { Playdate.find(1) }
  end

  def test_destroy_without_id
    assert_not_nil Playdate.find(1)

    post 'destroy'
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)

    assert_not_nil Playdate.find(1)
  end

  def test_edit_using_get
    get 'edit', :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:playdate)
    assert assigns(:playdate).valid?
  end

  def test_edit_using_post
    post 'edit', :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_edit_without_id
    post 'edit'
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)
  end

  def test_list
    get 'list'

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:playdates)
  end

  def test_new_using_get
    get 'new'

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:playdate)
  end

  def test_new_using_post
    num_playdates = Playdate.count

    post 'new', :playdate => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_playdates + 1, Playdate.count
  end

  def test_show
    get 'show', :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:playdate)
    assert assigns(:playdate).valid?
  end

  def test_show_without_id
    get 'show'

    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)
  end
end
