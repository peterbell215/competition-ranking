# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  def create
    super do |resource|
      resource.update_column(:last_login_at, Time.current) if resource.persisted?
    end
  end
end
