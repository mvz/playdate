require File.dirname(__FILE__) + '/../test_helper'

class LoginControllerTest < ActionController::TestCase
  render_views!

  def test_login_using_get
    get :login
    assert_response :success
    assert_template 'login'
    assert_select "h1", "Inloggen in Playdate"
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
    assert_redirected_to :controller => "login", :action => "login"
    get :edit, {}, {:user_id => players(:matijs).id }
    assert_response :success
    assert_select "h1", "Wachtwoord wijzigen"
  end

  def test_change_password_using_post
    post :edit, {:player => {:password => 'slurp', :password_confirmation => 'slurp'}}
    assert_response :redirect
    assert_redirected_to :controller => "login", :action => "login"
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
    assert_select "h1", "Uitloggen"
  end

  def test_logout_using_post
    post :logout, {}, {:user_id => players(:matijs).id }
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'login'
    assert_nil session[:user_id]
  end
end
