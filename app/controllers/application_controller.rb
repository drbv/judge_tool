class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from StandardError, with: :page_not_found unless Rails.env.development?
  helper_method :current_user, :current_round, :current_dance_round, :judge_status_class
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :redirect_to_login
  http_basic_authenticate_with name: Rails.application.secrets.basic_auth['name'], password: Rails.application.secrets.basic_auth['password'] if Rails.application.secrets.basic_auth
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
    admin.update_attribute(:pin, '1234')
    @current_user = admin
    beamer = User.new login: 'beamer'
    beamer.add_role :beamers
    beamer.save
    session[:user_id] = admin.id
  end

  def judge_status_class(judge, dance_round = current_dance_round)
    if judge.rated?(dance_round)
      if judge.open_discussion?(dance_round)
        'alert-info'
      else
        'alert-success'
      end
    else
      'alert-danger'
    end
  end

  def current_round
    @round ||= Round.active
  end

  def current_dance_round
    @dance_round ||= DanceRound.active
  end

  def render_xhr(template)
    if request.xhr?
      render template, layout: false
    else
      render template
    end
  end

  def reload_beamer
    $beamer.send 'reload'
  end

end
