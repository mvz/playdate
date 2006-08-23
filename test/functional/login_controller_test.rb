require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  fixtures :players

  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index_without_player
    get :index
    assert_redirected_to :action => "login"
  end

  def test_index_with_player
    get :index, {}, {:user_id => players(:matijs).id }
    assert_response :success
  end

  def test_login
    get :login
    assert_response :success
  end
end
