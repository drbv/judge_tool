class RoundsController < ApplicationController
  def index
    if User.count == 0
      generate_admin
      redirect_to tournament_users_path
    else
      if request.xhr?
        if @current_round = Round.active
          render json: [@current_round.id]
        else
          render json: []
        end
      else
        @rounds = Round.order(:position)
      end
    end
  end
end
