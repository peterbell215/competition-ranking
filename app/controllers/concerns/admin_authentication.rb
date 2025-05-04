module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_admin
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to rankings_path, alert: "You are not authorized to access this page."
    end
  end
end
