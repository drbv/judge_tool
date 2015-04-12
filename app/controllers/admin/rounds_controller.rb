class Admin::RoundsController < Admin::BaseController
  def index
    authorize Round, :admin_index?
    @rounds = Round.order(:start_time).all
  end

  def create
    access_database.import_round!
    redirect_to admin_rounds_path
  end
end
