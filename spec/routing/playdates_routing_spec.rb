# frozen_string_literal: true

require "rails_helper"

RSpec.describe "routes for Playdates", type: :routing do
  describe "routing" do
    it "no_route_to_destroy_without_id" do
      aggregate_failures do
        expect(delete: "playdate").not_to be_routable
        expect(delete: "playdates").not_to be_routable
        expect(delete: "playdates/1").to be_routable
      end
    end

    it "no_route_to_show_without_id" do
      aggregate_failures do
        expect(get: "playdate").not_to be_routable
        expect(get: "playdates").to route_to(controller: "playdates", action: "index")
        expect(get: "playdates/1").to be_routable
      end
    end
  end
end
