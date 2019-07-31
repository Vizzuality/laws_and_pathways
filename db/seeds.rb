# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

TargetType.create(name: 'Base Year Target')
TargetType.create(name: 'Baseline Scenario Target')
TargetType.create(name: 'Fixed Level Target')
TargetType.create(name: 'Intensity Target')
TargetType.create(name: 'Trajectory Target')

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
