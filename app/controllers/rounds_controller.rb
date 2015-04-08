class RoundsController < ApplicationController
  def index
    @rounds = Round.all
  end

  def show

  end
end
