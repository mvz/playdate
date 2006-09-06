require File.dirname(__FILE__) + '/../test_helper'
require 'playdates_controller'

# Re-raise errors caught by the controller.
class PlaydatesController; def rescue_action(e) raise e end; end

class PlaydatesControllerTest < Test::Unit::TestCase
  fixtures :playdates
  fixtures :availabilities
  fixtures :players

  def setup
    @controller = PlaydatesController.new
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
    assert_not_nil Playdate.find(1)

    get 'destroy', {:id => 1}, @playersession
    assert_response :redirect
    assert_redirected_to :action => 'edit'

    assert_not_nil Playdate.find(1)
  end

  def test_destroy_using_post
    pd = Playdate.find(1)
    assert_not_nil pd
    num_avs = Availability.count
    num_pd_avs = pd.availabilities.count

    post 'destroy', {:id => 1}, @playersession
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) { Playdate.find(1) }
    assert num_pd_avs > 0, "Test won't work if pd has no availabilities"
    assert_equal num_avs - num_pd_avs, Availability.count
  end

  def test_destroy_without_id
    assert_not_nil Playdate.find(1)

    post 'destroy', {}, @playersession
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)

    assert_not_nil Playdate.find(1)
  end

  def test_edit_using_get
    get 'edit', {:id => 1}, @playersession

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:playdate)
    assert assigns(:playdate).valid?
  end

  def test_edit_using_post
    post 'edit', {:id => 1}, @playersession
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

    assert_not_nil assigns(:playdates)
  end

  def test_new_using_get
    get 'new', {}, @playersession

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:playdate)
  end

  def test_new_using_post
    num_playdates = Playdate.count

    post 'new', {:playdate => {:day => "2006-03-11"}}, @playersession

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_playdates + 1, Playdate.count
  end

  def test_new_range_using_post
    num_playdates = Playdate.count

    post 'new', {:period => 2, :daytype => 6}, @playersession

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert Playdate.count >= num_playdates + 4

    post 'new', {:period => 3, :daytype => 7}, @playersession

    assert_response :success
  end

  def test_show
    get 'show', {:id => 1}, @playersession

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:playdate)
    assert assigns(:playdate).valid?
  end

  def test_show_without_id
    get 'show', {}, @playersession

    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)
  end
end
