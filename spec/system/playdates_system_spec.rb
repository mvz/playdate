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

  it "enables the admin to clean up playdates" do
    click_link "Speeldagen"

    expect(page).to have_content "Speeldagen"

    # FIXME: This shouldn't be needed.
    sleep 0.01

    accept_confirm do
      click_link "Opruimen"
    end

    expect(page).to have_text "Oude speeldagen zijn opgeruimd."
  end
end