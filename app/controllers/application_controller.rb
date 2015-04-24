class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from StandardError, with: :page_not_found unless Rails.env.development?
  helper_method :current_user
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :redirect_to_login
  http_basic_authenticate_with name: Rails.application.secrets.basic_auth.name, password: Rails.application.secrets.basic_auth.password if Rails.application.secrets.basic_auth
  private

  def redirect_to_login
    if current_user
      redirect_to root_path
    else
      redirect_to login_path
    end
  end

  def current_user
    @current_user ||= User.find_by id: session[:user_id]
  end

  def page_not_found
    render 'pages/page_not_found'
  end

  def generate_admin
    admin = User.new login: 'admin'
    admin.add_role :admin
    admin.save
    @current_user = admin
    session[:user_id] = admin.id
  end


end
