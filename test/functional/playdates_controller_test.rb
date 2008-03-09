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
    @adminsession = {:user_id => players(:admin).id }
  end

  def test_authorization
    playersession = {:user_id => players(:matijs).id }
    [:destroy, :edit, :list, :new, :show, :prune].each do |a|
      [:get, :post].each do |m|
        {"login" => {}, "main" => playersession}.each do |redirect,session|
          method(m).call(a, {}, session)
          assert_redirected_to :controller => redirect
        end
      end
    end
  end

  def test_destroy_using_get
    assert_not_nil Playdate.find(1)

    get 'destroy', {:id => 1}, @adminsession
    assert_response :redirect
    assert_redirected_to :action => 'edit'

    assert_not_nil Playdate.find(1)
  end

  def test_destroy_using_post
    pd = Playdate.find(1)
    assert_not_nil pd
    num_avs = Availability.count
    num_pd_avs = pd.availabilities.count
    assert num_pd_avs > 0, "Test won't work if pd has no availabilities"

    post 'destroy', {:id => 1}, @adminsession
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) { Playdate.find(1) }
    assert_equal num_avs - num_pd_avs, Availability.count
  end

  def test_destroy_without_id
    assert_not_nil Playdate.find(1)

    post 'destroy', {}, @adminsession
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)

    assert_not_nil Playdate.find(1)
  end

  def test_edit_using_get
    get 'edit', {:id => 1}, @adminsession

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:playdate)
    assert assigns(:playdate).valid?
  end

  def test_edit_using_post
    post 'edit', {:id => 1}, @adminsession
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_edit_without_id
    post 'edit', {}, @adminsession
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)
  end

  def test_list
    get 'list', {}, @adminsession

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:playdates)
  end

  def test_new_using_get
    get 'new', {}, @adminsession

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:playdate)
  end

  def test_new_using_post
    num_playdates = Playdate.count

    post 'new', {:playdate => {:day => "2006-03-11"}}, @adminsession

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_playdates + 1, Playdate.count
  end

  def test_new_range_using_post
    num_playdates = Playdate.count

    post 'new', {:period => 2, :daytype => 6}, @adminsession

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_operator Playdate.count, :>=, num_playdates + 4
    assert_operator Playdate.count, :<=, num_playdates + 10

    post 'new', {:period => 3, :daytype => 7}, @adminsession

    assert_response :success
  end

  def test_show
    get 'show', {:id => 1}, @adminsession

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:playdate)
    assert assigns(:playdate).valid?
  end

  def test_show_without_id
    get 'show', {}, @adminsession

    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert flash.has_key?(:notice)
  end

  def test_prune_using_get
    get 'prune', @adminsession

    assert_response :success
    assert_template 'prune'
  end

  def test_prune_using_get
    num_playdates = Playdate.count
    get 'prune', {}, @adminsession

    assert_response :success
    assert_template 'prune'
    assert Playdate.count == num_playdates
  end

  def test_prune_using_post
    num_playdates = Playdate.count
    assert num_playdates == 4
    post 'prune', {}, @adminsession

    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert Playdate.count == 2
    assert Playdate.find(:all).map {|pd| pd.id }.sort == [3, 4]
  end
end
