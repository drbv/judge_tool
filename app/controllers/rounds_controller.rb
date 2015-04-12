class RoundsController < ApplicationController
  def index
    if User.count == 0
      generate_admin
      redirect_to admin_users_path
    else
      if @dance_round = DanceRound.active
        render :dance_round
      elsif @round = Round.active
        render :show
      else
        @rounds = Round.all
      end
    end
  end
end
