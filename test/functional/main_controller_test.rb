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
    @playersession = {:user_id => players(:matijs).id }
  end

  def test_authorization
    [:index].each do |a|
      [:get, :post].each do |m|
        method(m).call(a, {}, {})
        assert_redirected_to :controller => "login", :action => "login"
      end
    end
  end

  def test_index_without_player
    get :index, {}, {}
    assert_redirected_to :action => "login"
  end

  def test_index
    get :index, {}, @playersession
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:playdates)
  end
end
