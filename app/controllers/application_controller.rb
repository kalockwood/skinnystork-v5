class ApplicationController < ActionController::Base
  #before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:name, :email, :password, :password_confirmation, roles: [])}
  end

  protect_from_forgery with: :exception

  before_action :authenticate_user!
   rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def after_sign_in_path_for(resource)
      if current_user.has_role? :admin
          users_path
      else
          root_path
      end 
      #edit_user_registration_path #sends user to edit settings page directly after loggin in
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
end


