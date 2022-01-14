# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionController, type: :controller do
  fixtures :players
  render_views

  it "login_intent" do
    get :new
    assert_response :success
    assert_template "new"
    assert_select "h1", "Inloggen in Playdate"
  end

  it "login" do
    matijs = players(:matijs)
    matijs.password = "gnoef!"
    matijs.password_confirmation = "gnoef!"
    matijs.save!
    post :create, params: {name: "matijs", password: "gnoef!"}
    assert_redirected_to controller: "main", action: "index"
    post :create, params: {name: "matijs", password: "zonk"}
    assert_response :success
    assert_template "new"
  end

  it "logout_intent" do
    get :edit
    assert_response :redirect
    get :edit, params: {}, session: playersession
    assert_response :success
    refute_nil session[:user_id]
    assert_template "edit"
    assert_select "h1", "Uitloggen"
  end

  it "logout" do
    post :destroy, params: {}, session: playersession
    assert_response :redirect
    assert_redirected_to controller: "session", action: "new"
    assert_nil session[:user_id]
  end

  private

  def playersession
    {user_id: players(:matijs).id}
  end
end
