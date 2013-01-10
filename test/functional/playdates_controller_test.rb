require File.dirname(__FILE__) + '/../test_helper'

class PlaydatesControllerTest < ActionController::TestCase
  def test_authorization
    playersession = {:user_id => players(:matijs).id }
    [:destroy, :edit, :index, :new, :show, :prune].each do |a|
      [:get, :post].each do |m|
        [
          [{}, "login", "login"],
          [playersession, "main", "index"]
        ].each do |session,controller,action|
          method(m).call(a, {:id => 1}, session)
          assert_redirected_to :controller => controller,
            :action => action
        end
      end
    end
  end

  def test_destroy
    pd = Playdate.find(1)
    assert_not_nil pd
    num_avs = Availability.count
    num_pd_avs = pd.availabilities.count
    assert num_pd_avs > 0, "Test won't work if pd has no availabilities"

    delete 'destroy', {:id => 1}, adminsession
    assert_response :redirect
    assert_redirected_to :controller => 'playdates', :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) { Playdate.find(1) }
    assert_equal num_avs - num_pd_avs, Availability.count
  end

  def test_no_route_to_destroy_without_id
    assert_not_routed action: 'destroy', controller: 'playdates'
  end

  def test_edit
    get 'edit', {:id => 1}, adminsession

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:playdate)
    assert assigns(:playdate).valid?

    assert_select "h1", "Editing playdate"

    # XXX: Rather technical test to check form will do PUT playdate_path(1)
    assert_select "form[action=?] input[value='put']", playdate_path(1)
    #
    # XXX: Rather technical test to check form will do DELETE playdate_path(1)
    assert_select "form[action=?] input[value='delete']", playdate_path(1)
  end

  def test_update
    put 'update', {:id => 1}, adminsession
    assert_response :redirect
    assert_redirected_to :controller => 'playdates', :action => 'show', :id => 1
  end

  def test_no_route_to_edit_without_id
    assert_not_routed action: 'edit', controller: 'playdates'
  end

  def test_index
    get 'index', {}, adminsession

    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:playdates)

    assert_select "h1", "Speeldagen"

    assert_select "a[href=?][data-method=delete]", playdate_path(1), "Verwijderen"
  end

  def test_new
    get 'new', {}, adminsession

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:playdate)

    assert_select "h1", "Nieuwe speeldagen"
    assert_select "form[action=?]", playdates_path
  end

  def test_create
    num_playdates = Playdate.count

    post 'create', {:playdate => {:day => "2006-03-11"}}, adminsession

    assert_response :redirect
    assert_redirected_to :controller => 'playdates', :action => 'index'

    assert_equal num_playdates + 1, Playdate.count
  end

  def test_create_with_range
    num_playdates = Playdate.count

    post 'create', {:period => 2, :daytype => 6}, adminsession

    assert_response :redirect
    assert_redirected_to :controller => 'playdates', :action => 'index'

    assert_operator Playdate.count, :>=, num_playdates + 4
    assert_operator Playdate.count, :<=, num_playdates + 10
  end

  def test_create_with_range_invalid_period
    post 'create', {:period => 3, :daytype => 6}, adminsession

    assert_template :new
  end

  def test_create_with_range_invalid_day_type
    post 'create', {:period => 2, :daytype => 7}, adminsession

    assert_template :new
  end

  def test_show
    get 'show', {:id => 1}, adminsession

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:playdate)
    assert assigns(:playdate).valid?

    assert_select "h1", "Speeldag: 2006-02-10"

    assert_select "a[href=?]", edit_playdate_availability_path(1, 1)
    # XXX: Rather technical test.
    assert_select "a[href=?][data-method=delete]", playdate_availability_path(1, 1)
  end

  def test_no_route_to_show_without_id
    assert_not_routed action: 'show', controller: 'playdates'
  end

  def test_prune_using_get
    get 'prune', adminsession

    assert_response :success
    assert_template 'prune'
  end

  def test_prune_using_get
    num_playdates = Playdate.count
    get 'prune', {}, adminsession

    assert_response :success
    assert_template 'prune'
    assert Playdate.count == num_playdates

    assert_select "h1", "Opruimen"
  end

  def test_prune_using_post
    num_playdates = Playdate.count
    assert num_playdates == 4
    post 'prune', {}, adminsession

    assert_response :redirect
    assert_redirected_to :controller => 'playdates', :action => 'index'
    assert Playdate.count == 2
    assert Playdate.find(:all).map {|pd| pd.id }.sort == [3, 4]
  end

  def adminsession
    {:user_id => players(:admin).id }
  end
end
