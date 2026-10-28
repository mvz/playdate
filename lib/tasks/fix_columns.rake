# frozen_string_literal: true

# rubocop:disable-next Rails/SkipsModelValidations
namespace :run_once do
  task fix_booleans: :environment do
    Player.where("is_admin = 't'").update_all(is_admin: 1)
    Player.where("is_admin = 'f'").update_all(is_admin: 0)
  end
end
