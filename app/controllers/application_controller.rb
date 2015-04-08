class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from StandardError, with: :page_not_found unless Rails.env.development?

  private

  def page_not_found
    render 'pages/page_not_found'
  end

  def current_user
    @current_user ||= User.find_by id: session[:user_id]
  end

  def generate_admin
    admin = User.new login: 'admin'
    admin.add_role :admin
    admin.save
    @current_user = admin
    session[:user_id] = admin.id
  end


end
