# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Playdates system", type: :system do
  fixtures :players, :playdates

  let(:admin) { players(:admin) }

  before do
    driven_by :selenium, using: :headless_firefox
    admin.update!(password: "foobar")

    visit "/"
    fill_in "Naam", with: "admin"
    fill_in "Wachtwoord", with: "foobar"
    click_button "Inloggen"
  end

  it "enables the admin to create playdates" do
    click_link "Speeldagen"
    click_link "Nieuwe speeldag"
    click_button "Opslaan"
    expect(page).to have_text "The new playdate was added"
  end

  it "enables the admin to create a range of playdates" do
    click_link "Speeldagen"
    old_count = Playdate.count
    click_link "Nieuwe speeldag"
    click_button "Reeks maken"
    expect(page).to have_text "Tonen"
    new_count = Playdate.count
    created_count = new_count - old_count
    expect(page)
      .to have_text I18n.t("playdates.notices.saved_new_range", count: created_count)
  end

  it "enables the admin to clean up playdates" do
    click_link "Speeldagen"

    expect(page).to have_content "Speeldagen"

    accept_confirm do
      click_link_or_button "Opruimen"
    end

    expect(page).to have_text I18n.t!("playdates.prune.notice")
  end
end
