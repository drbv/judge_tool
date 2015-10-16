class DanceRoundsController < ApplicationController
  def show
    @dance_round=current_dance_round || DanceRound.where(started: true, finished: true).last
    @round=current_round || Round.where(started: true, closed: true).last
  end
end
