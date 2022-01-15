# frozen_string_literal: true

require "rails_helper"

RSpec.describe "routes for Availabilities", type: :routing do
  describe "routing" do
    it "no_route_to_destroy_without_id" do
      expect(delete: "availability").not_to be_routable
      expect(delete: "availabilities").not_to be_routable
      expect(delete: "playdates/1/availability").not_to be_routable
      expect(delete: "playdates/1/availabilities").not_to be_routable
      expect(delete: "playdates/1/availabilities/2").to be_routable
    end

    it "no_route_to_edit_without_id" do
      expect(get: "availability/edit").not_to be_routable
      expect(get: "availabilities/edit").not_to be_routable
      expect(get: "playdates/1/availability/edit").not_to be_routable
      expect(get: "playdates/1/availabilities/edit").not_to be_routable
      expect(get: "playdates/1/availabilities/2/edit").to be_routable
    end
  end
end
