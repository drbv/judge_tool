class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.find_by login: params[:user][:login].downcase
    if @user && @user.pin == params[:user][:pin]
      session[:user_id] = @user.id
      case
        when @user.has_role?(:admin)
          redirect_to admin_users_path
        when @user.has_role?(:judge)
          redirect_to judges_dance_round_path
        when @user.has_role?(:beamer)
          redirect_to beamers_path
      end
    else
      @user = User.new login: params[:user][:login]
      render :new
    end
  end

  def destroy
    session.delete :user_id
    redirect_to root_path
  end
end
