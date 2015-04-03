class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from StandardError, with: :page_not_found unless Rails.env.development?

  private

  def page_not_found
    render 'pages/page_not_found'
  end


end
