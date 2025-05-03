# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create default admin user
admin = User.find_or_create_by!(email: "peter.bell@modaxo.com") do |user|
  user.name = "Peter Bell"
  user.password = "password"
  user.password_confirmation = "password"
  user.user_type = "admin"
end

puts "Default admin user created: #{admin.email}"
