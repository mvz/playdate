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

  def test_login_using_get
    get :login
    assert_response :success
    assert_template 'login'
  end

  def test_login_using_post
    matijs = players(:matijs)
    matijs.password = "gnoef!"
    matijs.password_confirmation = "gnoef!"
    matijs.save!
    post :login, {:name => "matijs", :password => "gnoef!"}
    assert_redirected_to :controller => "main", :action => "index"
    post :login, {:name => "matijs", :password => "zonk"}
    assert_response :success
    assert_template 'login'
  end
end
