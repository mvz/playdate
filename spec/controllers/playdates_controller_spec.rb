# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlaydatesController, type: :controller do
  render_views
  fixtures :players, :playdates, :availabilities

  describe "when not logged in" do
    [:destroy, :index, :new, :show, :prune].product([:get, :post]) do |(a, m)|
      it "requires login for #{m} #{a}" do
        send m, a, params: { id: 1 }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "when logged in as a regular player" do
    let(:playersession) { { user_id: players(:matijs).id } }

    [:destroy, :index, :new, :show, :prune].product([:get, :post]) do |(a, m)|
      it "denies access for #{m} #{a}" do
        send m, a, params: { id: 1 }, session: playersession
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "#destroy" do
    it "destroys the given playdate" do
      pd = Playdate.find(1)

      delete "destroy", params: { id: 1 }, session: adminsession

      aggregate_failures do
        expect { pd.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { Playdate.find(1) }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    it "destroys dependent availabilities" do
      pd = Playdate.find(1)
      num_pd_avs = pd.availabilities.count

      expect { delete "destroy", params: { id: 1 }, session: adminsession }
        .to change(Availability, :count).by(-num_pd_avs)
    end

    it "redirects to index with a message" do
      delete "destroy", params: { id: 1 }, session: adminsession
      aggregate_failures do
        expect(response).to redirect_to controller: "playdates", action: "index"
        expect(request).to set_flash[:notice].to I18n.t("flash.playdates.destroy.notice")
      end
    end
  end

  it "index" do
    get "index", params: {}, session: adminsession

    aggregate_failures do
      expect(response).to be_successful
      expect(response).to render_template "index"

      expect(assigns(:playdates)).not_to be_nil

      expect(response.body).to have_css "h1", text: "Speeldagen"

      expect(response.body).to have_button "Verwijderen"
    end
  end

  it "new" do
    get "new", params: {}, session: adminsession

    aggregate_failures do
      expect(response).to be_successful
      expect(response).to render_template "new"

      expect(assigns(:playdate)).not_to be_nil

      expect(response.body).to have_css "h1", text: "Nieuwe speeldagen"
      expect(response.body).to have_css "form[action=\"#{playdates_path}\"]"
    end
  end

  describe "#create" do
    it "can succesfully create a single date" do
      num_playdates = Playdate.count

      post "create", params: { playdate: { day: "2006-03-11" } }, session: adminsession

      aggregate_failures do
        expect(response).to redirect_to controller: "playdates", action: "index"
        expect(request).to set_flash[:notice].to I18n.t("flash.playdates.create.notice")
        expect(Playdate.count).to eq num_playdates + 1
        expect(response).to have_http_status :see_other
      end
    end

    it "renders new when date could not be created" do
      Playdate.create! day: "2006-03-11"
      post "create", params: { playdate: { day: "2006-03-11" } }, session: adminsession

      aggregate_failures do
        expect(response).to be_unprocessable
        expect(response).to render_template :new
      end
    end

    it "create_with_range" do
      num_playdates = Playdate.count

      post "create", params: { period: 2, daytype: 6 }, session: adminsession

      aggregate_failures do
        expect(response).to redirect_to controller: "playdates", action: "index"

        expect(Playdate.count).to be >= num_playdates + 4
        expect(Playdate.count).to be <= num_playdates + 10
      end
    end

    it "create_with_range_invalid_period" do
      post "create", params: { period: 3, daytype: 6 }, session: adminsession

      aggregate_failures do
        expect(response).to render_template :new
        expect(response).to be_unprocessable
      end
    end

    it "create_with_range_invalid_day_type" do
      post "create", params: { period: 2, daytype: 7 }, session: adminsession

      aggregate_failures do
        expect(response).to render_template :new
        expect(response).to be_unprocessable
      end
    end

    it "renders new with a message if no dates were created" do
      post "create", params: { period: 2, daytype: 6 }, session: adminsession
      post "create", params: { period: 2, daytype: 6 }, session: adminsession

      aggregate_failures do
        expect(response).to render_template :new
        expect(response).to be_unprocessable
        expect(response.body).to have_text I18n.t("playdates.notices.saved_none")
      end
    end
  end

  it "show" do
    get "show", params: { id: 1 }, session: adminsession

    aggregate_failures do
      expect(response).to be_successful
      expect(response).to render_template "show"

      expect(assigns(:playdate)).not_to be_nil
      expect(assigns(:playdate)).to be_valid

      expect(response.body).to have_css "h1", text: "Speeldag: 2006-02-10"

      expect(response.body)
        .to have_css "a[href=\"#{edit_playdate_availability_path(1, 1)}\"]"
      expect(response.body).to have_button "Verwijderen"
    end
  end

  it "prune_using_post" do
    today = Playdate.create!(day: Time.zone.today)
    tomorrow = Playdate.create!(day: Time.zone.tomorrow)
    old_count = Playdate.count

    post "prune", params: {}, session: adminsession

    aggregate_failures do
      expect(response).to redirect_to controller: "playdates", action: "index"
      expect(old_count).to eq 4
      expect(Playdate.count).to eq 2
      expect(Playdate.all).to contain_exactly today, tomorrow
    end
  end

  private

  def adminsession
    { user_id: players(:admin).id }
  end
end
