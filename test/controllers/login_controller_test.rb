# frozen_string_literal: true

require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  render_views!

  def test_edit_password
    get :edit
    assert_response :redirect
    assert_redirected_to controller: 'session', action: 'new'
    get :edit, params: {}, session: playersession
    assert_response :success
    assert_select 'h1', 'Wachtwoord wijzigen'
  end

  def test_update_password
    post :update, params: { player: { password: 'slurp', password_confirmation: 'slurp' } }
    assert_response :redirect
    assert_redirected_to controller: 'session', action: 'new'
    post :update,
      params: { player: { password: 'slurp', password_confirmation: 'slurp' } },
      session: playersession
    assert_response :redirect
    assert_redirected_to controller: 'main', action: 'index'
    post :update,
      params: { player: { password: 'slu', password_confirmation: 'slurp' } },
      session: playersession
    assert_response :success
  end

  def playersession
    { user_id: players(:matijs).id }
  end
end
