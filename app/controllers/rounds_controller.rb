class RoundsController < ApplicationController
  def index
    if User.count == 0
      generate_admin
      redirect_to admin_users_path
    else
      @rounds = Round.all
    end
  end

  def show

  end
end
