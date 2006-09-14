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

  def test_change_password_using_get
    get :edit
    assert_response :redirect
    assert_redirected_to :action => "login"
    get :edit, {}, {:user_id => players(:matijs).id }
    assert_response :success
  end

  def test_change_password_using_post
    post :edit, {:player => {:password => 'slurp', :password_confirmation => 'slurp'}}
    assert_response :redirect
    assert_redirected_to :action => "login"
    post :edit, {:player => {:password => 'slurp', :password_confirmation => 'slurp'}}, {:user_id => players(:matijs).id }
    assert_response :redirect
    assert_redirected_to :controller => "main", :action => "index"
    post :edit, {:player => {:password => 'slu', :password_confirmation => 'slurp'}}, {:user_id => players(:matijs).id }
    assert_response :success
  end

  def test_logout_using_get
    get :logout
    assert_response :redirect
    get :logout, {}, {:user_id => players(:matijs).id }
    assert_response :success
    assert_not_nil session[:user_id]
    assert_template 'logout'
  end

  def test_logout_using_post
    post :logout, {}, {:user_id => players(:matijs).id }
    assert_response :redirect
    assert_redirected_to 'login'
    assert_nil session[:user_id]
  end
end
