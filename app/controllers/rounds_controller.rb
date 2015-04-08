class RoundsController < ApplicationController
  def index
    if User.empty?
      generate_admin
      redirect_to admin_users_path
    end
    @rounds = Round.all
  end

  def show

  end
end
