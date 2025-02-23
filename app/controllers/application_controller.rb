class ApplicationController < ActionController::Base
  include ApplicationHelper
  include RoutesHelper
  include Pagy::Backend
  include Pundit::Authorization

  before_action :authenticate_user!

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  helper_method :current_user, :support_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def sign_in_user
    @sign_in_user ||= DfESignInUser.load_from_session(session, service: current_service)
  end

  def current_user
    @current_user ||= sign_in_user&.user
  end

  def user_signed_in?
    current_user.present?
  end

  def after_sign_in_path
    if current_user.support_user?
      support_root_path
    else
      organisations_path
    end
  end

  def after_sign_out_path
    sign_in_path
  end

  def authenticate_user!
    return if current_user

    session[:requested_path] = request.fullpath

    redirect_to sign_in_path
  end

  def support_controller?
    false
  end

  def user_not_authorized
    redirect_back fallback_location: root_path, alert: t("you_cannot_perform_this_action")
  end
end
