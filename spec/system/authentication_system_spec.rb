# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication system", type: :system do
  fixtures :players

  let(:admin) { players(:admin) }

  before do
    driven_by(:rack_test)
  end

  it "enables the user to log in and out" do
    visit "/"
    fill_in Player.human_attribute_name(:email), with: "admin@example.com"
    fill_in Player.human_attribute_name(:password), with: "foobar"
    click_button "Inloggen"

    expect(page).to have_text("Ingelogd als #{admin.full_name}")

    click_button "Uitloggen"

    expect(page).not_to have_text("Ingelogd als #{admin.full_name}")
    expect(page)
      .to have_text "Je dient je aan te melden of in te schrijven om door te gaan."
  end
end
