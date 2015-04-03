class RoundsController < ApplicationController
  def index
    @rounds = Round.all
  end
end
