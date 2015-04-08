class RoundsController < ApplicationController
  def index
    if User.empty?
      generate_admin
      redirect_to admin_users_path
    else
      @rounds = Round.all
    end
  end

  def show

  end
end
