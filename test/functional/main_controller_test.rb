require File.dirname(__FILE__) + '/../test_helper'
require 'main_controller'

# Re-raise errors caught by the controller.
class MainController; def rescue_action(e) raise e end; end

class MainControllerTest < Test::Unit::TestCase
  fixtures :playdates
  fixtures :availabilities
  fixtures :players

  def setup
    @controller = MainController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_authorization
    [:index, :edit].each do |a|
      [:get, :post].each do |m|
        method(m).call(a, {}, {})
        assert_redirected_to :controller => "login", :action => "login"
      end
    end
  end

  def test_index
    get :index, {}, {:user_id => players(:matijs).id }
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:playdates)
  end

  def test_index_as_admin
    get :index, {}, {:user_id => players(:admin).id }
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:playdates)
  end

  def test_edit_using_get
    get :edit, {}, {:user_id => players(:matijs).id }
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:playdates)
  end

  def test_edit_using_post
    post :edit, {:availability => { 1 => {:status => 2}, 2 => {:status => 3} } }, {:user_id => players(:robert).id}
    assert_response :redirect
    assert_redirected_to :action => "index"
    assert Availability.count == 4
    newavs = players(:robert).availabilities.sort_by {|a| a.playdate_id}
    assert newavs.map{|a| [a.playdate_id, a.status]}.flatten == [1, 2, 2, 3]
  end
end
