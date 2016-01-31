class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.find_by login: params[:user][:login]
    if @user && @user.pin == params[:user][:pin]
      session[:user_id] = @user.id
      redirect_to (@user.has_role?(:admin) ? tournament_users_path : judges_dance_round_path)
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
