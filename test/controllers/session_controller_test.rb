# frozen_string_literal: true

require "test_helper"

class SessionControllerTest < ActionController::TestCase
  render_views!

  def test_login_intent
    get :new
    assert_response :success
    assert_template "new"
    assert_select "h1", "Inloggen in Playdate"
  end

  def test_login
    matijs = players(:matijs)
    matijs.password = "gnoef!"
    matijs.password_confirmation = "gnoef!"
    matijs.save!
    post :create, params: { name: "matijs", password: "gnoef!" }
    assert_redirected_to controller: "main", action: "index"
    post :create, params: { name: "matijs", password: "zonk" }
    assert_response :success
    assert_template "new"
  end

  def test_logout_intent
    get :edit
    assert_response :redirect
    get :edit, params: {}, session: playersession
    assert_response :success
    assert_not_nil session[:user_id]
    assert_template "edit"
    assert_select "h1", "Uitloggen"
  end

  def test_logout
    post :destroy, params: {}, session: playersession
    assert_response :redirect
    assert_redirected_to controller: "session", action: "new"
    assert_nil session[:user_id]
  end

  def playersession
    { user_id: players(:matijs).id }
  end
end
