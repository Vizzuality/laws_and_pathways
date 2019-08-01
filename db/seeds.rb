ActiveRecord::Migration.say_with_time('Loading target types') do
  types = [
    'Base Year Target',
    'Baseline Scenario Target',
    'Fixed Level Target',
    'Intensity Target',
    'Trajectory Target'
  ]

  types.each { |type| TargetType.create(name: type) }
end

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
