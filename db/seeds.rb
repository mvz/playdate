# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin = Player.create(name: 'admin',
                      password: 'trundle',
                      password_confirmation: 'trundle',
                      is_admin: true)
admin.valid? or raise 'No user created?'
