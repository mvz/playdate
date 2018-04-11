# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
namespace :run_once do
  task fix_booleans: :environment do
    Player.where("is_admin = 't'").update_all(is_admin: 1)
    Player.where("is_admin = 'f'").update_all(is_admin: 0)
  end
end
# rubocop:enable Rails/SkipsModelValidations
